package gandang.auth.controller;

import gandang.auth.dto.SocialAuthRequestDto;
import gandang.auth.dto.TokenResponseDto;
import gandang.auth.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/kakao")
    public ResponseEntity<TokenResponseDto> kakaoAuth(
        @RequestBody SocialAuthRequestDto requestDto) {
        TokenResponseDto tokenResponse = authService.kakaoAuth(requestDto);
        return ResponseEntity.ok(tokenResponse);
    }

    @PostMapping("/google")
    public ResponseEntity<TokenResponseDto> googleAuth(
        @RequestBody SocialAuthRequestDto requestDto) {
        TokenResponseDto tokenResponse = authService.googleAuth(requestDto);
        return ResponseEntity.ok(tokenResponse);
    }
}