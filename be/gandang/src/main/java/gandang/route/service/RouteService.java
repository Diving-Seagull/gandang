package gandang.route.service;

import static gandang.common.exception.ExceptionCode.ROUTE_ALREADY_STARRED;
import static gandang.common.exception.ExceptionCode.ROUTE_NOT_FOUND;
import static gandang.common.exception.ExceptionCode.ROUTE_STAR_NOT_FOUND;

import gandang.common.exception.CustomException;
import gandang.common.utils.AddressParser;
import gandang.member.entity.Member;
import gandang.member.service.MemberService;
import gandang.route.dto.PopularDestinationDto;
import gandang.route.dto.RouteRequestDto;
import gandang.route.dto.RouteResponseDto;
import gandang.route.dto.RouteStarResponseDto;
import gandang.route.entity.Route;
import gandang.route.entity.RouteStar;
import gandang.route.repository.RouteRepository;
import gandang.route.repository.RouteStarRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RouteService {

    private final RouteRepository routeRepository;
    private final RouteStarRepository routeStarRepository;
    private final MemberService memberService;

    @Transactional(readOnly = true)
    public Page<RouteResponseDto> getRoutes(String email, Pageable pageable) {
        Member member = memberService.getMemberEntityByEmail(email);

        // 즐겨찾기 목록 조회
        List<Long> starredRouteIds = routeStarRepository.findRouteIdsByMember(member);

        // 경로 조회
        Page<Route> routes = routeRepository.findAllByMemberOrderByStarredAndCreatedAt(
            member,
            starredRouteIds,
            pageable
        );

        return routes.map(route -> RouteResponseDto.builder()
            .id(route.getId())
            .startLatitude(route.getStartLatitude())
            .startLongitude(route.getStartLongitude())
            .startAddress(route.getStartAddress())
            .endLatitude(route.getEndLatitude())
            .endLongitude(route.getEndLongitude())
            .endAddress(route.getEndAddress())
            .distance(route.getDistance())
            .createdAt(route.getCreatedAt())
            .isStarred(starredRouteIds.contains(route.getId()))
            .build());
    }

    @Transactional(readOnly = true)
    public Page<RouteResponseDto> getStarredRoutes(String email, Pageable pageable) {
        Member member = memberService.getMemberEntityByEmail(email);

        Page<Route> starredRoutes = routeRepository.findAllByRouteStarsMember(member, pageable);

        return starredRoutes.map(route -> RouteResponseDto.builder()
            .id(route.getId())
            .startLatitude(route.getStartLatitude())
            .startLongitude(route.getStartLongitude())
            .startAddress(route.getStartAddress())
            .endLatitude(route.getEndLatitude())
            .endLongitude(route.getEndLongitude())
            .endAddress(route.getEndAddress())
            .distance(route.getDistance())
            .createdAt(route.getCreatedAt())
            .isStarred(true)
            .build());
    }

    @Transactional(readOnly = true)
    public List<PopularDestinationDto> getRecommendedRoutes(String currentAddress) {
        AddressParser.AddressComponents components = AddressParser.parse(currentAddress);
        String searchArea = components.getDistrict();

        return routeRepository.findPopularDestinations(
            searchArea,
            PageRequest.of(0, 10)
        );
    }

    @Transactional
    public RouteResponseDto createRoute(String email, RouteRequestDto requestDto) {
        Member member = memberService.getMemberEntityByEmail(email);

        Route route = Route.builder()
            .member(member)
            .startLatitude(requestDto.getStartLatitude())
            .startLongitude(requestDto.getStartLongitude())
            .startAddress(requestDto.getStartAddress())
            .endLatitude(requestDto.getEndLatitude())
            .endLongitude(requestDto.getEndLongitude())
            .endAddress(requestDto.getEndAddress())
            .distance(requestDto.getDistance())
            .build();

        Route savedRoute = routeRepository.save(route);

        return RouteResponseDto.builder()
            .id(savedRoute.getId())
            .startLatitude(savedRoute.getStartLatitude())
            .startLongitude(savedRoute.getStartLongitude())
            .startAddress(savedRoute.getStartAddress())
            .endLatitude(savedRoute.getEndLatitude())
            .endLongitude(savedRoute.getEndLongitude())
            .endAddress(savedRoute.getEndAddress())
            .distance(savedRoute.getDistance())
            .createdAt(savedRoute.getCreatedAt())
            .isStarred(false)
            .build();
    }

    @Transactional
    public RouteStarResponseDto addStar(String email, Long routeId) {
        Member member = memberService.getMemberEntityByEmail(email);
        Route route = routeRepository.findById(routeId)
            .orElseThrow(() -> new CustomException(ROUTE_NOT_FOUND));

        // 이미 즐겨찾기한 경우 예외 처리
        if (routeStarRepository.existsByMemberAndRoute(member, route)) {
            throw new CustomException(ROUTE_ALREADY_STARRED);
        }

        RouteStar routeStar = RouteStar.builder()
            .member(member)
            .route(route)
            .build();

        RouteStar savedStar = routeStarRepository.save(routeStar);

        return RouteStarResponseDto.builder()
            .routeId(route.getId())
            .starId(savedStar.getId())
            .starredAt(savedStar.getCreatedAt())
            .build();
    }

    @Transactional
    public void removeStar(String email, Long routeId) {
        Member member = memberService.getMemberEntityByEmail(email);
        Route route = routeRepository.findById(routeId)
            .orElseThrow(() -> new CustomException(ROUTE_NOT_FOUND));

        RouteStar routeStar = routeStarRepository.findByMemberAndRoute(member, route)
            .orElseThrow(() -> new CustomException(ROUTE_STAR_NOT_FOUND));

        routeStarRepository.delete(routeStar);
    }
}