package gandang.notification.service;

import static gandang.global.exception.ExceptionCode.INVALID_TEAM_MEMBERS;
import static gandang.global.exception.ExceptionCode.NOTIFICATION_ERROR;
import static gandang.global.exception.ExceptionCode.NOT_TEAM_LEADER;
import static gandang.global.exception.ExceptionCode.TEAM_MISMATCH;
import static gandang.global.exception.ExceptionCode.TEAM_NOT_FOUND;

import com.google.firebase.messaging.AndroidConfig;
import com.google.firebase.messaging.AndroidNotification;
import com.google.firebase.messaging.ApnsConfig;
import com.google.firebase.messaging.Aps;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import java.util.List;
import java.util.concurrent.ExecutionException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import gandang.global.exception.CustomException;
import gandang.global.utils.TranslationUtil;
import gandang.member.entity.Member;
import gandang.member.repository.MemberRepository;
import gandang.notification.dto.NotificationRequestDto;
import gandang.team.entity.Team;
import gandang.team.repository.TeamRepository;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationService {

    private final MemberRepository memberRepository;
    private final TeamRepository teamRepository;
    private final TranslationUtil translationUtil;

    public void sendTeamAlert(Long teamId, NotificationRequestDto requestDto, Member sender) {
        if (!sender.isLeader()) {
            throw new CustomException(NOT_TEAM_LEADER);
        }

        Team team = teamRepository.findById(teamId)
            .orElseThrow(() -> new CustomException(TEAM_NOT_FOUND));

        if (!sender.getTeam().getId().equals(team.getId())) {
            throw new CustomException(TEAM_MISMATCH);
        }

        List<Member> targetMembers = memberRepository.findAllById(requestDto.getTargetMemberIds());

        if (targetMembers.stream()
            .anyMatch(member -> !member.getTeam().getId().equals(team.getId()))) {
            throw new CustomException(INVALID_TEAM_MEMBERS);
        }

        String title = "팀 알림";
        String body = sender.getName() + " 테스트";

        sendNotificationToTeam(targetMembers, title, body, null);
    }

    public void sendNotificationToTeam(List<Member> teamMembers, String defaultTitle, String defaultBody,
        String imageUrl) {
        teamMembers.forEach(member -> {
            if (member.getFirebaseToken() != null) {
                String title = translationUtil.translateText(defaultTitle, member.getLanguageCode());
                String body = translationUtil.translateText(defaultBody, member.getLanguageCode());
                sendNotification(member, title, body, imageUrl);
            }
        });
    }

    private void sendNotification(Member member, String title, String body, String imageUrl) {
        Message.Builder messageBuilder = Message.builder()
            .setToken(member.getFirebaseToken());

        Notification.Builder notificationBuilder = Notification.builder()
            .setTitle(title)
            .setBody(body);

        AndroidNotification.Builder androidNotificationBuilder = AndroidNotification.builder()
            .setSound("default");

        ApnsConfig.Builder apnsConfigBuilder = ApnsConfig.builder()
            .setAps(Aps.builder().setSound("default").build());

        if (imageUrl != null && !imageUrl.isEmpty()) {
            notificationBuilder.setImage(imageUrl);
            androidNotificationBuilder.setImage(imageUrl);
            apnsConfigBuilder.putCustomData("image", imageUrl);
        }

        messageBuilder.setNotification(notificationBuilder.build())
            .setAndroidConfig(AndroidConfig.builder()
                .setNotification(androidNotificationBuilder.build())
                .build())
            .setApnsConfig(apnsConfigBuilder.build());

        Message message = messageBuilder.build();

        try {
            String response = FirebaseMessaging.getInstance().sendAsync(message).get();
            log.info("Successfully sent message to member ID {}: {}", member.getId(), response);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Interrupted while sending message to member ID {}", member.getId(), e);
            throw new CustomException(NOTIFICATION_ERROR);
        } catch (ExecutionException e) {
            log.error("Failed to send message to member ID {}", member.getId(), e);
            throw new CustomException(NOTIFICATION_ERROR);
        }
    }

    // 팀장의 위치가 업데이트되었을 때 팀원들에게 알림을 보내는 메서드
    public void sendLocationUpdateNotificationToTeam(Member leader) {
        List<Member> teamMembers = memberRepository.findByTeam(leader.getTeam());

        teamMembers.removeIf(member -> member.getId().equals(leader.getId()));

        String title = "팀장님의 새로운 위치를 확인해 주세요";
        String body = leader.getName() + " 팀장님이 새로운 위치로 이동하셨습니다. 위치 정보를 확인해 주세요.";

        sendNotificationToTeam(teamMembers, title, body, null);
    }
}