package gandang.route.repository;

import gandang.member.entity.Member;
import gandang.route.dto.PopularDestinationDto;
import gandang.route.entity.Route;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface RouteRepository extends JpaRepository<Route, Long> {

    @Query("SELECT r FROM Route r " +
        "WHERE r.member = :member " +
        "ORDER BY " +
        "CASE WHEN r.id IN :starredIds THEN 0 ELSE 1 END, " +
        "r.createdAt DESC")
    Page<Route> findAllByMemberOrderByStarredAndCreatedAt(
        @Param("member") Member member,
        @Param("starredIds") List<Long> starredIds,
        Pageable pageable
    );

    @Query("SELECT r FROM Route r JOIN r.routeStars rs WHERE rs.member = :member")
    Page<Route> findAllByRouteStarsMember(@Param("member") Member member, Pageable pageable);

    @Query("SELECT new gandang.route.dto.PopularDestinationDto(" +
        "r.endAddress, r.endLatitude, r.endLongitude, r.endName, COUNT(r), " +
        "MAX(r.createdAt), MIN(r.distance)) " +
        "FROM Route r " +
        "WHERE r.startAddress LIKE %:area% " +
        "GROUP BY r.endAddress, r.endLatitude, r.endLongitude, r.endName " +
        "ORDER BY COUNT(r) DESC, MAX(r.createdAt) DESC")
    List<PopularDestinationDto> findPopularDestinations(
        @Param("area") String area,
        Pageable pageable
    );
}