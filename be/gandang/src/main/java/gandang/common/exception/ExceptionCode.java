package gandang.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
@Getter
public enum ExceptionCode {
    // 사용자 관련 에러
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 사용자를 찾을 수 없습니다."),
    USER_FORBIDDEN(HttpStatus.FORBIDDEN, "권한이 없습니다."),
    USER_EMAIL_ALREADY_EXISTS(HttpStatus.CONFLICT, "이미 존재하는 이메일입니다."),
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다."),

    // Apple 인증 관련
    APPLE_TOKEN_INVALID(HttpStatus.UNAUTHORIZED, "유효하지 않은 Apple 토큰입니다."),
    APPLE_TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "만료된 Apple 토큰입니다."),
    APPLE_TOKEN_PARSE_ERROR(HttpStatus.BAD_REQUEST, "Apple 토큰 파싱 중 오류가 발생했습니다."),
    APPLE_EMAIL_MISSING(HttpStatus.BAD_REQUEST, "Apple 계정의 이메일 정보가 제공되지 않았습니다."),
    APPLE_USER_DISABLED(HttpStatus.FORBIDDEN, "비활성화된 Apple 계정입니다."),
    APPLE_AUTH_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Apple 인증 서버 오류가 발생했습니다."),

    // Route
    ROUTE_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 경로를 찾을 수 없습니다."),
    ROUTE_ACCESS_DENIED(HttpStatus.FORBIDDEN, "해당 경로에 대한 접근 권한이 없습니다."),
    ROUTE_ALREADY_STARRED(HttpStatus.CONFLICT, "이미 즐겨찾기한 경로입니다."),
    ROUTE_STAR_NOT_FOUND(HttpStatus.NOT_FOUND, "즐겨찾기하지 않은 경로입니다."),
    INVALID_ROUTE_COORDINATES(HttpStatus.BAD_REQUEST, "유효하지 않은 경로 좌표입니다."),

    // 잘못된 접근,
    SOCIAL_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "소셜 토큰이 제공되지 않았습니다."),
    JWT_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "JWT 토큰이 제공되지 않았습니다."),
    FIREBASE_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "파이어베이스 토큰이 제공되지 않았습니다."),
    BAD_APPROACH(HttpStatus.BAD_REQUEST, "잘못된 접근입니다."),

    NOTIFICATION_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Firebase 알림 전송 중 오류가 발생했습니다."),

    ADDRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 위도와 경도에 대한 주소를 찾을 수 없습니다."),
    GEOCODING_API_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Google Geocoding API 호출 중 오류가 발생했습니다."),

    MEMBER_LOCATION_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 사용자의 위치를 찾을 수 없습니다."),

    LANGUAGE_DETECTION_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "언어 감지 중 오류가 발생했습니다."),
    TRANSLATION_FAILED(HttpStatus.INTERNAL_SERVER_ERROR, "번역 중 오류가 발생했습니다."),

    ;

    private final HttpStatus httpStatus;
    private final String message;
}