import os
import json
import osmnx as ox
import pandas as pd
import networkx as nx
import numpy as np
from shapely.geometry import LineString
import pickle
from pyproj import Geod
import sys

class CoastalPathFinder:
    _instance = None
    _initialized = False

    def __new__(cls, *args, **kwargs):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self, csv_path, network_path):
        if self._initialized:
            return

        try:
            print("1. 데이터 로딩 중...")
            self.intersections = pd.read_csv(csv_path)
            print(f"- {len(self.intersections)}개의 해안도로 교차점 로드됨")

            print("\n2. 도로 네트워크 로딩 중...")
            with open(network_path, 'rb') as f:
                network_data = pickle.load(f)

            self.nodes = network_data['nodes']
            self.edges = network_data['edges']
            self.G = ox.graph_from_gdfs(self.nodes, self.edges)

            print("- 도로 네트워크 로드 완료")
            self.coastal_nodes = set(self.intersections['node_id'].values)

            # 엣지 검색을 위한 딕셔너리 생성
            self.edge_lookup = {}
            for idx_tuple in self.edges.index:
                self.edge_lookup[(idx_tuple[0], idx_tuple[1])] = (idx_tuple, False)
                self.edge_lookup[(idx_tuple[1], idx_tuple[0])] = (idx_tuple, True)

            # 교차점 좌표를 딕셔너리로 저장
            self.intersection_lookup = {
                (row['latitude'], row['longitude']): row
                for _, row in self.intersections.iterrows()
            }

            self._initialized = True

        except Exception as e:
            print(f"초기화 중 오류 발생: {str(e)}")
            raise

    def find_route(self, start_lat, start_lon, end_lat, end_lon):
        print("\n3. 경로 탐색 중...")

        start_idx, start_node = self._find_nearest_intersection(start_lat, start_lon)
        end_idx, end_node = self._find_nearest_intersection(end_lat, end_lon)
        print(f"- 출발지 근처 교차점: {start_node} (인덱스: {start_idx})")
        print(f"- 목적지 근처 교차점: {end_node} (인덱스: {end_idx})")

        waypoints = self._get_waypoints(start_idx, end_idx)
        print(f"- 경유할 해안도로 교차점 수: {len(waypoints)}개")

        # 관광지 체크
        tourspots = [wp for wp in waypoints if 'type' in wp and 'tourspot' in str(wp['type']).lower()]
        if tourspots:
            print("\n- 경로에 포함된 관광지:")
            for spot in tourspots:
                print(f"  * {spot.get('name', '이름 없음')} (위도: {spot['latitude']}, 경도: {spot['longitude']})")

        route = []
        # 출발지 -> 첫 교차점
        first_segment = nx.shortest_path(
            self.G,
            start_node,
            waypoints[0]['node_id'],
            weight='length'
        )
        route.extend(first_segment[:-1])

        # 교차점들 사이의 경로
        for i in range(len(waypoints)-1):
            segment = nx.shortest_path(
                self.G,
                waypoints[i]['node_id'],
                waypoints[i+1]['node_id'],
                weight='length'
            )
            route.extend(segment[:-1])

        # 마지막 교차점 -> 도착지
        last_segment = nx.shortest_path(
            self.G,
            waypoints[-1]['node_id'],
            end_node,
            weight='length'
        )
        route.extend(last_segment)

        print(f"- 경로 찾음 (총 {len(route)}개 노드)")

        return route

    def get_interpolated_coordinates(self, route, interval=100):
        coordinates = []
        self.total_distance = 0
        geod = Geod(ellps='WGS84')
        prev_coord = None

        edges_index_tuples = list(self.edges.index)

        for i in range(len(route)-1):
            u, v = route[i], route[i+1]
            try:
                edge_info = self.edge_lookup.get((u, v))
                if edge_info is not None:
                    edge_tuple, reverse = edge_info
                else:
                    continue

                # edge 데이터 가져오기
                edge_data = self.edges.loc[edge_tuple]
                line = edge_data.geometry
                coords = list(line.coords)

                # 방향이 반대인 경우 좌표 순서 뒤집기
                if reverse:
                    coords = coords[::-1]

                # 실제 미터 단위 거리 계산
                segment_length = 0
                segment_distances = []

                for j in range(len(coords)-1):
                    lon1, lat1 = coords[j]
                    lon2, lat2 = coords[j+1]
                    _, _, distance = geod.inv(lon1, lat1, lon2, lat2)
                    segment_length += distance
                    segment_distances.append(segment_length)

                # 보간할 점의 개수 계산
                if segment_length < interval:
                    interpolated_points = [coords[0], coords[-1]]
                else:
                    num_points = int(segment_length / interval) + 1
                    target_distances = np.linspace(0, segment_length, num_points)

                    # 각 목표 거리에 해당하는 실제 좌표 계산
                    interpolated_points = []
                    curr_coord_idx = 0

                    for target_d in target_distances:
                        while (curr_coord_idx < len(segment_distances) and
                            segment_distances[curr_coord_idx] < target_d):
                            curr_coord_idx += 1

                        if curr_coord_idx == 0:
                            interpolated_points.append(coords[0])
                        elif curr_coord_idx >= len(coords):
                            interpolated_points.append(coords[-1])
                        else:
                            prev_d = segment_distances[curr_coord_idx-1] if curr_coord_idx > 0 else 0
                            curr_d = segment_distances[curr_coord_idx]
                            ratio = (target_d - prev_d) / (curr_d - prev_d)

                            prev_coord_point = coords[curr_coord_idx-1]
                            curr_coord_point = coords[curr_coord_idx]

                            lon = prev_coord_point[0] + ratio * (curr_coord_point[0] - prev_coord_point[0])
                            lat = prev_coord_point[1] + ratio * (curr_coord_point[1] - prev_coord_point[1])
                            interpolated_points.append((lon, lat))

                # 좌표 변환 및 저장 (중복 제거)
                for point in interpolated_points:
                    lat, lon = point[1], point[0]

                    # 원본 교차점인지 확인
                    lookup_key = (lat, lon)
                    original_info = self.intersection_lookup.get(lookup_key)

                    if original_info is not None:
                        type_info = original_info['type']
                        name_info = original_info['name']
                    else:
                        type_info = 'road'
                        name_info = 'road'

                    coord = {
                        "lat": lat,
                        "lng": lon,
                        "type": type_info,
                        "name": name_info
                    }

                    if prev_coord is None or (
                        abs(coord["lat"] - prev_coord["lat"]) > 1e-7 or
                        abs(coord["lng"] - prev_coord["lng"]) > 1e-7
                    ):
                        coordinates.append(coord)
                        prev_coord = coord

                self.total_distance += segment_length

            except Exception as e:
                continue

        print(f"- 총 거리: {self.total_distance/1000:.2f}km")
        return coordinates

    def save_result(self, route):
        coords = self.get_interpolated_coordinates(route)
        has_tourspot = any(coord["type"].lower() == "tourspot" for coord in coords)

        result = {
            "totalDistance": self.total_distance/1000,  # km로 변환
            "hasTourspot": has_tourspot,
            "path": coords
        }

        # JSON으로 출력
        print("RESULT_START")
        print(json.dumps(result))
        print("RESULT_END")

    def _find_nearest_intersection(self, lat, lon):
        min_dist = float('inf')
        nearest_idx = None
        nearest_node = None

        for idx, row in self.intersections.iterrows():
            dist = self._haversine_distance(
                lat, lon,
                row['latitude'], row['longitude']
            )
            if dist < min_dist:
                min_dist = dist
                nearest_idx = idx
                nearest_node = row['node_id']

        return nearest_idx, nearest_node

    def _get_waypoints(self, start_idx, end_idx):
        total_points = len(self.intersections)

        if start_idx <= end_idx:
            clockwise = list(range(start_idx, end_idx + 1))
            counterclockwise = list(range(start_idx, -1, -1)) + list(range(total_points-1, end_idx-1, -1))
        else:
            clockwise = list(range(start_idx, total_points)) + list(range(0, end_idx + 1))
            counterclockwise = list(range(start_idx, end_idx - 1, -1))

        path_indices = clockwise if len(clockwise) <= len(counterclockwise) else counterclockwise
        return self.intersections.iloc[path_indices].to_dict('records')

    def _haversine_distance(self, lat1, lon1, lat2, lon2):
        R = 6371
        lat1, lon1, lat2, lon2 = map(np.radians, [lat1, lon1, lat2, lon2])
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = np.sin(dlat/2)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon/2)**2
        c = 2 * np.arctan2(np.sqrt(a), np.sqrt(1-a))
        return R * c

def main():
    try:
        if len(sys.argv) < 7:
            print("Usage: python coastal_path_finder.py start_lat start_lon end_lat end_lon csv_path network_path")
            sys.exit(1)

        start_lat = float(sys.argv[1])
        start_lon = float(sys.argv[2])
        end_lat = float(sys.argv[3])
        end_lon = float(sys.argv[4])
        csv_path = sys.argv[5]
        network_path = sys.argv[6]

        pathfinder = CoastalPathFinder(csv_path, network_path)
        route = pathfinder.find_route(start_lat, start_lon, end_lat, end_lon)
        pathfinder.save_result(route)

    except Exception as e:
        print(f"오류 발생: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()