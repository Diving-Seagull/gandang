package gandang.member.controller;

import gandang.auth.LoginMember;
import gandang.member.dto.MemberInitRequestDto;
import gandang.member.dto.MemberResponseDto;
import gandang.member.entity.Member;
import gandang.member.service.MemberService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/member")
public class MemberController {

    private final MemberService memberService;

    public MemberController(MemberService memberService) {
        this.memberService = memberService;
    }

    @GetMapping
    public ResponseEntity<MemberResponseDto> getMember(@LoginMember Member member) {
        return ResponseEntity.ok(memberService.getMember(member));
    }

    @GetMapping("/{email}")
    public ResponseEntity<MemberResponseDto> getMemberProfile(@PathVariable String email) {
        return ResponseEntity.ok(memberService.getMemberByEmail(email));
    }

    @PutMapping
    public ResponseEntity<MemberResponseDto> initMember(@LoginMember Member member,
        @Valid @RequestBody MemberInitRequestDto initRequestDto) {
        return ResponseEntity.ok(memberService.initMember(member, initRequestDto));
    }

    @DeleteMapping
    public ResponseEntity<Void> deleteMember(@LoginMember Member member) {
        memberService.deleteMember(member);
        return ResponseEntity.noContent().build();
    }
}