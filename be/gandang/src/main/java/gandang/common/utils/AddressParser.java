package gandang.common.utils;

import lombok.Getter;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AddressParser {

    @Getter
    public static class AddressComponents {
        private final String province;      // 시/도
        private final String city;          // 시/군/구
        private final String district;      // 읍/면/동
        private final String detail;        // 나머지 상세주소

        public AddressComponents(String province, String city, String district, String detail) {
            this.province = province;
            this.city = city;
            this.district = district;
            this.detail = detail;
        }
    }

    private static final Pattern ADDRESS_PATTERN = Pattern.compile(
        "^(?:([가-힣]+(?:특별시|광역시|특별자치시|특별자치도|도))?\\s*)" +    // 시/도
            "(?:([가-힣]+(?:시|군|구))?\\s*)" +                                   // 시/군/구
            "(?:([가-힣]+(?:읍|면|동|가|리))?\\s*)" +                            // 읍/면/동
            "(?:(.+))?$"                                                         // 나머지 상세주소
    );

    public static AddressComponents parse(String fullAddress) {
        Matcher matcher = ADDRESS_PATTERN.matcher(fullAddress);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Invalid address format");
        }

        String province = matcher.group(1) != null ? matcher.group(1).trim() : "";
        String city = matcher.group(2) != null ? matcher.group(2).trim() : "";
        String district = matcher.group(3) != null ? matcher.group(3).trim() : "";
        String detail = matcher.group(4) != null ? matcher.group(4).trim() : "";

        return new AddressComponents(province, city, district, detail);
    }

    public static boolean isSameArea(String address1, String address2) {
        AddressComponents comp1 = parse(address1);
        AddressComponents comp2 = parse(address2);

        return comp1.getDistrict().equals(comp2.getDistrict()) &&
            comp1.getCity().equals(comp2.getCity()) &&
            comp1.getProvince().equals(comp2.getProvince());
    }
}