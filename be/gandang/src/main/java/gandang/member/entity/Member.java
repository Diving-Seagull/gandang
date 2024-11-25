package gandang.member.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import gandang.member.enums.Role;
import gandang.member.enums.SocialType;
import gandang.team.entity.Team;

@Entity
@Table(name = "members")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String email;

    @Column(length = 20)
    private String name;

    @Column(length = 50)
    private String description;

    private String profile;

    @Enumerated(EnumType.STRING)
    private SocialType socialType;

    private String firebaseToken;

    @Column(nullable = false)
    @ColumnDefault("true")
    private boolean isEnabled = true;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @Column(nullable = false, length = 10)
    @ColumnDefault("'ko'")
    private String languageCode = "ko";

    @Builder
    private Member(Long id, String email, String name, String description, String profile,
        SocialType socialType, String firebaseToken, String languageCode) {
        this.id = id;
        this.email = email;
        this.name = name;
        this.description = description;
        this.profile = profile;
        this.socialType = socialType;
        this.firebaseToken = firebaseToken;
        this.languageCode = (languageCode != null) ? languageCode : "ko";
    }

    public void initMember(Role role, String name, String description, String profile, String languageCode) {
        this.role = (role != null) ? role : this.role;
        this.description = description;
        this.deviceUuid = deviceUuid;

        if (name != null) {
            this.name = name;
        }
        if (profile != null) {
            this.profile = profile;
        }
        if (team != null) {
            this.team = team;
        }
        if (languageCode != null) {
            this.languageCode = languageCode;
        }
    }

    public void changeLanguage(String languageCode) {
        this.languageCode = languageCode;
    }

    public void disable() {
        this.isEnabled = false;
    }
}