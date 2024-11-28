package gandang.route.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class RouteRequestDto {

    @NotNull(message = "출발지 위도를 입력해주세요")
    private Double startLatitude;

    @NotNull(message = "출발지 경도를 입력해주세요")
    private Double startLongitude;

    @NotNull(message = "도착지 위도를 입력해주세요")
    private Double endLatitude;

    @NotNull(message = "도착지 경도를 입력해주세요")
    private Double endLongitude;
}