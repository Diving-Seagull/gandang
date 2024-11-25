package gandang.member.repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import gandang.member.entity.Member;
import gandang.member.enums.Role;
import gandang.team.entity.Team;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    boolean existsById(Long id);

    Optional<Member> findByEmail(String email);

    List<Member> findByTeam(Team team);

    Optional<Member> findByTeamAndRole(Team team, Role role);
}
