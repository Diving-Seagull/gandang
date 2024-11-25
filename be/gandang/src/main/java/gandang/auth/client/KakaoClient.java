package gandang.auth.client;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import gandang.auth.dto.KakaoUserInfo;
import gandang.global.exception.CustomException;
import gandang.global.exception.ExceptionCode;

@Component
@RequiredArgsConstructor
public class KakaoClient {

    private final RestTemplate restTemplate;
    private static final String KAKAO_USER_INFO_URI = "https://kapi.kakao.com/v2/user/me";

    public KakaoUserInfo getKakaoUserInfo(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            return restTemplate.exchange(KAKAO_USER_INFO_URI, HttpMethod.GET, entity,
                KakaoUserInfo.class).getBody();
        } catch (Exception e) {
            throw new CustomException(ExceptionCode.TOKEN_EXPIRED);
        }
    }
}