package gandang.bicycleStation.service;

import gandang.bicycleStation.dto.NearestBicycleStationResponseDto;
import gandang.bicycleStation.entity.BicycleStation;
import gandang.bicycleStation.repository.BicycleStationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BicycleStationService {

    private final BicycleStationRepository bicycleStationRepository;

    public NearestBicycleStationResponseDto findNearest(Double latitude, Double longitude) {
        BicycleStation nearestStation = bicycleStationRepository.findNearest(latitude, longitude);

        if (nearestStation == null) {
            throw new IllegalStateException("주변에 이용 가능한 자전거 정류소가 없습니다.");
        }

        double distanceInMeters = calculateDistance(
            latitude, longitude,
            nearestStation.getLatitude(), nearestStation.getLongitude()
        );

        return NearestBicycleStationResponseDto.builder()
            .stationName(nearestStation.getName())
            .address(nearestStation.getAddress())
            .latitude(nearestStation.getLatitude())
            .longitude(nearestStation.getLongitude())
            .distanceInMeters(distanceInMeters)
            .build();
    }

    // Haversine 공식을 사용한 두 지점 간의 거리 계산 (미터 단위)
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double R = 6371000; // 지구의 반지름 (미터)
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
}