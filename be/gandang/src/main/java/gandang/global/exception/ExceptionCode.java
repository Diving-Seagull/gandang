package gandang.global.exception;

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


    // 잘못된 접근,
    SOCIAL_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "소셜 토큰이 제공되지 않았습니다."),
    JWT_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "JWT 토큰이 제공되지 않았습니다."),
    FIREBASE_TOKEN_MISSING(HttpStatus.BAD_REQUEST, "파이어베이스 토큰이 제공되지 않았습니다."),
    BAD_APPROACH(HttpStatus.BAD_REQUEST, "잘못된 접근입니다."),

    NOTIFICATION_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Firebase 알림 전송 중 오류가 발생했습니다."),

    ADDRESS_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 위도와 경도에 대한 주소를 찾을 수 없습니다."),
    GEOCODING_API_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "Google Geocoding API 호출 중 오류가 발생했습니다."),

    MEMBER_LOCATION_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 사용자의 위치를 찾을 수 없습니다."),


    ;

    private final HttpStatus httpStatus;
    private final String message;
}