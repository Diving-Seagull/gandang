package gandang.bicycleStation.repository;

import gandang.bicycleStation.entity.BicycleStation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BicycleStationRepository extends JpaRepository<BicycleStation, Long> {

    // Haversine 공식을 사용하여 가장 가까운 정류소를 찾는 쿼리
    @Query(value =
        "SELECT *, " +
            "(6371000 * acos(cos(radians(:latitude)) * cos(radians(b.latitude)) * " +
            "cos(radians(b.longitude) - radians(:longitude)) + " +
            "sin(radians(:latitude)) * sin(radians(b.latitude)))) AS distance " +
            "FROM bicycle_stations b " +
            "ORDER BY distance " +
            "LIMIT 1", nativeQuery = true)
    BicycleStation findNearest(@Param("latitude") Double latitude,
        @Param("longitude") Double longitude);
}