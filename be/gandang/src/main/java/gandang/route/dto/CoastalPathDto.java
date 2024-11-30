package gandang.route.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CoastalPathDto {

    private Double lat;
    private Double lng;
    private String type;
    private String name;
}