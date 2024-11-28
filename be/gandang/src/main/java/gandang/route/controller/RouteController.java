package gandang.route.controller;

import gandang.auth.LoginMember;
import gandang.member.entity.Member;
import gandang.route.dto.RouteRequestDto;
import gandang.route.dto.RouteResponseDto;
import gandang.route.dto.RouteStarResponseDto;
import gandang.route.service.RouteService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class RouteController {

    private final RouteService routeService;

    @GetMapping
    public ResponseEntity<Page<RouteResponseDto>> getRoutes(
        @LoginMember Member member,
        @PageableDefault(sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<RouteResponseDto> routes = routeService.getRoutes(member.getEmail(), pageable);
        return ResponseEntity.ok(routes);
    }

    @PostMapping
    public ResponseEntity<RouteResponseDto> createRoute(@LoginMember Member member,
        @Valid @RequestBody RouteRequestDto requestDto) {
        RouteResponseDto responseDto = routeService.createRoute(member.getEmail(), requestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(responseDto);
    }

    @PostMapping("/{routeId}/star")
    public ResponseEntity<RouteStarResponseDto> addStar(@LoginMember Member member,
        @PathVariable Long routeId) {
        RouteStarResponseDto responseDto = routeService.addStar(member.getEmail(), routeId);
        return ResponseEntity.status(HttpStatus.CREATED).body(responseDto);
    }

    @DeleteMapping("/{routeId}/star")
    public ResponseEntity<Void> removeStar(@LoginMember Member member, @PathVariable Long routeId) {
        routeService.removeStar(member.getEmail(), routeId);
        return ResponseEntity.noContent().build();
    }
}