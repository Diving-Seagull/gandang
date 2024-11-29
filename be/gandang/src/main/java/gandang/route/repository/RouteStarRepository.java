package gandang.route.repository;

import gandang.member.entity.Member;
import gandang.route.entity.Route;
import gandang.route.entity.RouteStar;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RouteStarRepository extends JpaRepository<RouteStar, Long> {

    boolean existsByMemberAndRoute(Member member, Route route);

    Optional<RouteStar> findByMemberAndRoute(Member member, Route route);

    @Query("SELECT rs.route.id FROM RouteStar rs WHERE rs.member = :member")
    List<Long> findRouteIdsByMember(@Param("member") Member member);
}