package gandang.auth;

import static gandang.common.exception.ExceptionCode.JWT_TOKEN_MISSING;
import static gandang.common.exception.ExceptionCode.TOKEN_EXPIRED;

import gandang.common.exception.CustomException;
import gandang.common.utils.JwtUtil;
import gandang.member.entity.Member;
import gandang.member.service.MemberService;
import lombok.AllArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Component
@AllArgsConstructor
public class LoginMemberArgumentResolver implements HandlerMethodArgumentResolver {

    private final JwtUtil jwtUtil;
    private final MemberService memberService;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.getParameterAnnotation(LoginMember.class) != null
            && parameter.getParameterType().equals(Member.class);
    }

    @Override
    public Member resolveArgument(MethodParameter parameter, ModelAndViewContainer mavContainer,
        NativeWebRequest webRequest, WebDataBinderFactory binderFactory) throws Exception {
        String token = extractToken(webRequest);
        if (token == null) {
            throw new CustomException(JWT_TOKEN_MISSING);
        }

        if (jwtUtil.isTokenExpired(token)) {
            throw new CustomException(TOKEN_EXPIRED);
        }

        String memberEmail = jwtUtil.extractMemberEmail(token);
        return memberService.getMemberEntityByEmail(memberEmail);
    }

    private String extractToken(NativeWebRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}