package gandang.member.service;

import static gandang.common.exception.ExceptionCode.USER_NOT_FOUND;

import gandang.common.exception.CustomException;
import gandang.member.dto.MemberInitRequestDto;
import gandang.member.dto.MemberResponseDto;
import gandang.member.entity.Member;
import gandang.member.repository.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;

    @Transactional
    public Member getMemberEntityByEmail(String memberEmail) {
        return memberRepository.findByEmail(memberEmail)
            .orElseThrow(() -> new CustomException(USER_NOT_FOUND));
    }

    @Transactional
    public MemberResponseDto getMember(Member member) {
        return MemberResponseDto.from(member);
    }

    @Transactional
    public MemberResponseDto getMemberByEmail(String memberEmail) {
        return MemberResponseDto.from(memberRepository.findByEmail(memberEmail)
            .orElseThrow(() -> new CustomException(USER_NOT_FOUND)));
    }

    @Transactional
    public MemberResponseDto initMember(Member member, MemberInitRequestDto initDto) {
        member.initMember(
            initDto.getName(),
            initDto.getProfileImage(),
            initDto.getLanguageCode()
        );

        Member updatedMember = memberRepository.save(member);
        return MemberResponseDto.from(updatedMember);
    }

    @Transactional
    public void deleteMember(Member member) {
        member.disable();
        memberRepository.save(member);
    }
}
