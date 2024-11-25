package gandang.member.service;

import static gandang.global.exception.ExceptionCode.USER_NOT_FOUND;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import gandang.global.exception.CustomException;
import gandang.member.dto.MemberInitRequestDto;
import gandang.member.dto.MemberResponseDto;
import gandang.member.entity.Member;
import gandang.member.enums.Role;
import gandang.member.repository.MemberRepository;
import gandang.memberlocation.service.MemberLocationService;
import gandang.team.entity.Team;
import gandang.team.service.TeamService;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final TeamService teamService;
    private final MemberLocationService memberLocationService;

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
        Role newRole = initDto.getRole();
        Team team = null;

        if (newRole == Role.LEADER) {
            team = teamService.createTeam(member);
            memberLocationService.createInitialLocationForLeader(member);
        } else if (newRole == Role.TEAMMATE && initDto.getTeamCode() != null) {
            team = teamService.findTeamByCode(initDto.getTeamCode());
        }

        member.initMember(
            newRole,
            initDto.getName(),
            initDto.getDescription(),
            initDto.getProfileImage(),
            initDto.getDeviceUuid(),
            team,
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
