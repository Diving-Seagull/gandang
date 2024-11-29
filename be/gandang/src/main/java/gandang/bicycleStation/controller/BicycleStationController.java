package gandang.bicycleStation.controller;

import gandang.bicycleStation.dto.NearestBicycleStationResponseDto;
import gandang.bicycleStation.service.BicycleStationService;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/bicycle-stations")
@RequiredArgsConstructor
public class BicycleStationController {

    private final BicycleStationService bicycleStationService;

    @GetMapping("/nearest")
    public ResponseEntity<NearestBicycleStationResponseDto> findNearest(
        @RequestParam @DecimalMin(value = "33.20", message = "서귀포시 남쪽 끝 위도(약 33.20) 보다 커야 합니다")
        @DecimalMax(value = "33.50", message = "서귀포시 북쪽 끝 위도(약 33.50) 보다 작아야 합니다") Double latitude,

        @RequestParam @DecimalMin(value = "126.15", message = "서귀포시 서쪽 끝 경도(약 126.15) 보다 커야 합니다")
        @DecimalMax(value = "126.95", message = "서귀포시 동쪽 끝 경도(약 126.95) 보다 작아야 합니다") Double longitude
    ) {
        return ResponseEntity.ok(bicycleStationService.findNearest(latitude, longitude));
    }
}