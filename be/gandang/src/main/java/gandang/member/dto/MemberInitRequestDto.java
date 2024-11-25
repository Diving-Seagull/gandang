package gandang.member.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import gandang.global.validation.ValidLanguageCode;
import gandang.member.enums.Role;

@Getter
@NoArgsConstructor
public class MemberInitRequestDto {

    private String profileImage;

    @Size(max = 20, message = "이름은 20자를 초과할 수 없습니다.")
    private String name;

    @ValidLanguageCode(message = "유효한 ISO 언어 코드를 입력해주세요.")
    @Size(min = 2, max = 10, message = "언어 코드는 2자 이상 10자 이하여야 합니다.")
    private String languageCode;
}