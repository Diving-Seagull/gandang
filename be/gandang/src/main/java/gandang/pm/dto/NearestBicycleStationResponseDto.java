package gandang.pm.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class NearestBicycleStationResponseDto {

    private String stationName;
    private String address;
    private Double latitude;
    private Double longitude;
    private Double distanceInMeters;  // 사용자 위치로부터의 거리(미터)
}