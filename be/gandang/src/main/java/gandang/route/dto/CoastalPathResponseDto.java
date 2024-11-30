package gandang.route.dto;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoastalPathResponseDto {
    private Double totalDistance;  // km 단위
    private boolean hasTourspot;
    private List<CoastalPathDto> path;
}