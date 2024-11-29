package gandang.route.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class RouteResponseDto {

    private Long id;
    private Double startLatitude;
    private Double startLongitude;
    private String startAddress;
    private Double endLatitude;
    private Double endLongitude;
    private String endAddress;
    private Double distance;
    private LocalDateTime createdAt;
    private boolean isStarred;
}