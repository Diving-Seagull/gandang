package gandang.route.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import java.time.LocalDateTime;
import lombok.Getter;

@Getter
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class PopularDestinationDto {

    private final String endAddress;
    private final Double endLatitude;
    private final Double endLongitude;
    private final String endName;
    private final Long visitCount;
    private final LocalDateTime lastVisitedAt;
    private final Double distance;

    public PopularDestinationDto(String endAddress, Double endLatitude, Double endLongitude,
        String endName,
        Long visitCount, LocalDateTime lastVisitedAt, Double distance) {
        this.endAddress = endAddress;
        this.endLatitude = endLatitude;
        this.endLongitude = endLongitude;
        this.endName = endName;
        this.visitCount = visitCount;
        this.lastVisitedAt = lastVisitedAt;
        this.distance = distance;
    }
}