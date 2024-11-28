package gandang.pm.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class NearestBicycleStationRequestDto {

    @NotNull(message = "위도는 필수 입력값입니다")
    @DecimalMin(value = "33.20", message = "서귀포시 남쪽 끝 위도(약 33.20) 보다 커야 합니다")
    @DecimalMax(value = "33.50", message = "서귀포시 북쪽 끝 위도(약 33.40) 보다 작아야 합니다")
    private Double latitude;

    @NotNull(message = "경도는 필수 입력값입니다")
    @DecimalMin(value = "126.15", message = "서귀포시 서쪽 끝 경도(약 126.15) 보다 커야 합니다")
    @DecimalMax(value = "126.95", message = "서귀포시 동쪽 끝 경도(약 126.95) 보다 작아야 합니다")
    private Double longitude;
}
