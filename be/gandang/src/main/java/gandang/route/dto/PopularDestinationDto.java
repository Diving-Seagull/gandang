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
    private final Long visitCount;
    private final LocalDateTime lastVisitedAt;

    public PopularDestinationDto(String endAddress, Double endLatitude, Double endLongitude,
        Long visitCount, LocalDateTime lastVisitedAt) {
        this.endAddress = endAddress;
        this.endLatitude = endLatitude;
        this.endLongitude = endLongitude;
        this.visitCount = visitCount;
        this.lastVisitedAt = lastVisitedAt;
    }
}