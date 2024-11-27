package gandang.auth.service;

import gandang.auth.client.AppleClient;
import gandang.auth.client.GoogleClient;
import gandang.auth.client.KakaoClient;
import gandang.auth.dto.AppleUserInfo;
import gandang.auth.dto.GoogleUserInfo;
import gandang.auth.dto.KakaoUserInfo;
import gandang.auth.dto.SocialAuthRequestDto;
import gandang.auth.dto.TokenResponseDto;
import gandang.common.exception.CustomException;
import gandang.common.exception.ExceptionCode;
import gandang.common.utils.JwtUtil;
import gandang.member.entity.Member;
import gandang.member.enums.SocialType;
import gandang.member.repository.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);
    private final MemberRepository memberRepository;
    private final JwtUtil jwtUtil;
    private final KakaoClient kakaoClient;
    private final GoogleClient googleClient;
    private final AppleClient appleClient;

    @Transactional
    public TokenResponseDto kakaoAuth(SocialAuthRequestDto requestDto) {
        KakaoUserInfo kakaoUserInfo = kakaoClient.getKakaoUserInfo(requestDto.getSocialToken());

        Member member = memberRepository.findByEmail(kakaoUserInfo.getEmail())
            .orElseGet(() -> registerNewKakaoMember(kakaoUserInfo, requestDto.getFirebaseToken()));

        String jwtToken = jwtUtil.generateToken(member.getEmail());

        logger.info("Generated JWT Token: {}", jwtToken);
        return new TokenResponseDto(jwtToken);
    }

    @Transactional
    public TokenResponseDto googleAuth(SocialAuthRequestDto requestDto) {
        GoogleUserInfo googleUserInfo = googleClient.getGoogleUserInfo(requestDto.getSocialToken());

        Member member = memberRepository.findByEmail(googleUserInfo.getEmail())
            .orElseGet(
                () -> registerNewGoogleMember(googleUserInfo, requestDto.getFirebaseToken()));

        String jwtToken = jwtUtil.generateToken(member.getEmail());
        return new TokenResponseDto(jwtToken);
    }

    @Transactional
    public TokenResponseDto appleAuth(SocialAuthRequestDto requestDto) {
        if (requestDto.getSocialToken() == null) {
            log.error("Social token is missing for Apple authentication");
            throw new CustomException(ExceptionCode.SOCIAL_TOKEN_MISSING);
        }

        log.info("Starting Apple authentication process");
        AppleUserInfo appleUserInfo = appleClient.getAppleUserInfo(requestDto.getSocialToken());

        try {
            Member member = memberRepository.findByEmail(appleUserInfo.getEmail())
                .orElseGet(() -> {
                    log.info("Registering new Apple user with email: {}",
                        appleUserInfo.getEmail().replaceFirst("(^[^@]{3})[^@]*", "$1***"));
                    return registerNewAppleMember(appleUserInfo, requestDto.getFirebaseToken());
                });

            if (!member.isEnabled()) {
                log.error("Attempted login with disabled Apple account: {}",
                    member.getEmail().replaceFirst("(^[^@]{3})[^@]*", "$1***"));
                throw new CustomException(ExceptionCode.APPLE_USER_DISABLED);
            }

            String jwtToken = jwtUtil.generateToken(member.getEmail());
            log.info("Successfully generated JWT token for Apple user");

            return new TokenResponseDto(jwtToken);

        } catch (DataIntegrityViolationException e) {
            log.error("Database error during Apple user registration", e);
            throw new CustomException(ExceptionCode.USER_EMAIL_ALREADY_EXISTS);
        }
    }

    private Member registerNewKakaoMember(KakaoUserInfo kakaoUserInfo, String firebaseToken) {
        if (firebaseToken == null) {
            throw new CustomException(ExceptionCode.FIREBASE_TOKEN_MISSING);
        }
        Member newMember = Member.builder()
            .email(kakaoUserInfo.getEmail())
            .name(kakaoUserInfo.getNickname())
            .profileImage(kakaoUserInfo.getProfileImageUrl())
            .socialType(SocialType.KAKAO)
            .firebaseToken(firebaseToken)
            .build();
        return memberRepository.save(newMember);
    }

    private Member registerNewGoogleMember(GoogleUserInfo googleUserInfo, String firebaseToken) {
        if (firebaseToken == null) {
            throw new CustomException(ExceptionCode.FIREBASE_TOKEN_MISSING);
        }
        Member newMember = Member.builder()
            .email(googleUserInfo.getEmail())
            .name(googleUserInfo.getName())
            .profileImage(googleUserInfo.getPicture())
            .socialType(SocialType.GOOGLE)
            .firebaseToken(firebaseToken)
            .build();
        return memberRepository.save(newMember);
    }

    private Member registerNewAppleMember(AppleUserInfo appleUserInfo, String firebaseToken) {
        if (firebaseToken == null) {
            throw new CustomException(ExceptionCode.FIREBASE_TOKEN_MISSING);
        }
        Member newMember = Member.builder()
            .email(appleUserInfo.getEmail())
            .name(appleUserInfo.getName())
            .socialType(SocialType.APPLE)
            .firebaseToken(firebaseToken)
            .build();
        return memberRepository.save(newMember);
    }
}
