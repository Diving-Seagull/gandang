package gandang.member.dto;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import gandang.member.entity.Member;
import gandang.member.enums.SocialType;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class MemberResponseDto {

    private Long id;
    private String email;
    private String name;
    private String profileImage;
    private SocialType socialType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String languageCode;

    public static MemberResponseDto from(Member member) {
        return MemberResponseDto.builder()
            .id(member.getId())
            .email(member.getEmail())
            .name(member.getName())
            .profileImage(member.getProfileImage())
            .socialType(member.getSocialType())
            .createdAt(member.getCreatedAt())
            .updatedAt(member.getUpdatedAt())
            .languageCode(member.getLanguageCode())
            .build();
    }
}
