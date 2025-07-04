package edu.uclm.esi.iso2.users.domain.users.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import edu.uclm.esi.iso2.users.domain.users.model.Usuario;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByEmail(String email);

    Optional<Usuario> findByTokenVerificacion(String token);

    boolean existsByEmail(String email);
}
