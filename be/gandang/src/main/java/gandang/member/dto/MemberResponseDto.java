package gandang.member.dto;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import gandang.member.entity.Member;
import gandang.member.enums.Role;
import gandang.member.enums.SocialType;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberResponseDto {

    private Long id;
    private String email;
    private String name;
    private String description;
    private String profile;
    private SocialType socialType;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String languageCode;

    public static MemberResponseDto from(Member member) {
        return MemberResponseDto.builder()
            .id(member.getId())
            .email(member.getEmail())
            .name(member.getName())
            .description(member.getDescription())
            .profile(member.getProfile())
            .socialType(member.getSocialType())
            .createdAt(member.getCreatedAt())
            .updatedAt(member.getUpdatedAt())
            .languageCode(member.getLanguageCode())
            .build();
    }
}
