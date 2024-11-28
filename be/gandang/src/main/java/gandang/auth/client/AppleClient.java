package gandang.auth.client;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.crypto.RSASSAVerifier;
import com.nimbusds.jose.jwk.JWK;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import gandang.auth.dto.AppleUserInfo;
import gandang.common.exception.CustomException;
import gandang.common.exception.ExceptionCode;
import java.security.interfaces.RSAPublicKey;
import java.util.List;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Component
@RequiredArgsConstructor
public class AppleClient {

    private static final String APPLE_PUBLIC_KEYS_URL = "https://appleid.apple.com/auth/keys";
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    public AppleUserInfo getAppleUserInfo(String identityToken) {
        try {
            log.info("Fetching Apple public keys");
            ApplePublicKeyResponse keyResponse = restTemplate.getForObject(APPLE_PUBLIC_KEYS_URL,
                ApplePublicKeyResponse.class);

            SignedJWT signedJWT = SignedJWT.parse(identityToken);
            String kid = signedJWT.getHeader().getKeyID();

            RSAPublicKey publicKey = findMatchingKey(keyResponse, kid);

            JWSVerifier verifier = new RSASSAVerifier(publicKey);
            if (!signedJWT.verify(verifier)) {
                throw new CustomException(ExceptionCode.APPLE_TOKEN_INVALID);
            }

            JWTClaimsSet claims = signedJWT.getJWTClaimsSet();
            return AppleUserInfo.builder()
                .email(claims.getStringClaim("email"))
                .sub(claims.getSubject())
                .build();

        } catch (Exception e) {
            log.error("Error verifying Apple token", e);
            throw new CustomException(ExceptionCode.APPLE_AUTH_SERVER_ERROR);
        }
    }

    private RSAPublicKey findMatchingKey(ApplePublicKeyResponse keyResponse, String kid)
        throws Exception {
        ApplePublicKey matchingKey = keyResponse.getKeys().stream()
            .filter(key -> key.getKid().equals(kid))
            .findFirst()
            .orElseThrow(() -> new CustomException(ExceptionCode.APPLE_TOKEN_INVALID));

        return (RSAPublicKey) JWK.parse(objectMapper.writeValueAsString(matchingKey)).toRSAKey()
            .toPublicKey();
    }
}

@Data
class ApplePublicKeyResponse {

    private List<ApplePublicKey> keys;
}

@Data
class ApplePublicKey {

    private String kty;
    private String kid;
    private String use;
    private String alg;
    private String n;
    private String e;
}