package gandang.pm.enums;

import lombok.Getter;

@Getter
public enum PMType {
    BICYCLE("자전거"),
    KICKBOARD("전동킥보드");

    private final String description;

    PMType(String description) {
        this.description = description;
    }
}