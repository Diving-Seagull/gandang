package gandang.route.entity;

import gandang.member.entity.Member;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Entity
@Table(name = "routes")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class Route {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "member_id")
    private Member member;

    // 출발지 정보
    @Column(nullable = false)
    private Double startLatitude;

    @Column(nullable = false)
    private Double startLongitude;

    @Column(nullable = false)
    private String startAddress;

    // 도착지 정보
    @Column(nullable = false)
    private Double endLatitude;

    @Column(nullable = false)
    private Double endLongitude;

    @Column(nullable = false)
    private String endAddress;

    // 이동 거리 (단위: 미터)
    @Column(nullable = false)
    private Double distance;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "route", cascade = CascadeType.REMOVE)
    private List<RouteStar> routeStars = new ArrayList<>();

    @Builder
    public Route(Member member, Double startLatitude, Double startLongitude, String startAddress,
        Double endLatitude, Double endLongitude, String endAddress, Double distance) {
        this.member = member;
        this.startLatitude = startLatitude;
        this.startLongitude = startLongitude;
        this.startAddress = startAddress;
        this.endLatitude = endLatitude;
        this.endLongitude = endLongitude;
        this.endAddress = endAddress;
        this.distance = distance;
    }
}
