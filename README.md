# Unoverse 🎲🔥

**Unoverse** é um aplicativo Flutter desenvolvido para facilitar o controle de pontuação em partidas de Uno jogadas entre amigos. Ele substitui o uso de planilhas manuais, automatizando o registro e a visualização das partidas e pontuações.

## 📱 Funcionalidades

- Registro de partidas com até 3 colocados
- Sistema de pontuação automática, Exemplo:
  - 🥇 1º lugar: 3 pontos
  - 🥈 2º lugar: 2 pontos
  - 🥉 3º lugar: 1 ponto
- Tela inicial com **cards de grupos**
- Integração com Firebase
- Authenticação com email e senha
- Inclusão de novos membros no grupo via convite
- Gerencimaneto de permissões por grupo (Master, Admin e User)


## 🛠 Tecnologias Utilizadas

- **Flutter** (SDK de desenvolvimento multiplataforma)
- **Dart** (linguagem principal)
- **Firebase** (autenticação e banco de dados)
- Gerenciamento de estado com `Provider`
  

## 📸 Capturas de Tela

<table>
  <tr>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/e896ecd6-904f-4658-9688-14c123b0c832" alt="Imagem 1" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Tela de grupos</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/bbf189df-74c3-48b0-bd45-54a75a9becf8" alt="Imagem 2" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Criar grupo</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/0cb2a332-6d04-4d22-b882-b78a7cfcba94" alt="Imagem 3" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Entrar no grupo</em>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/0d7451a7-06d8-4dae-955b-9851bf444903" alt="Imagem 4" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Tela do grupo</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/ef499b72-2522-45c3-a16e-a6492f16390e" alt="Imagem 5" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Criar jogador</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/ea97839c-f9a4-425d-ba72-5b45182abc25" alt="Imagem 6" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Adicionar partida</em>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/d10958e5-6d1a-4f0d-92e5-0af385a1a61c" alt="Imagem 7" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Gerar convite</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/c2581697-8073-4145-b746-dbd131174106" alt="Imagem 8" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Tela de login</em>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/98133654-83cf-4547-b95a-e5aa4efa9c35" alt="Imagem 9" style="width: 100%; max-width: 378px; height: auto; display: block; margin: auto;">
      <br>
      <em>Tela de registro</em>
    </td>
  </tr>
</table>


## 🧑‍💻 Autor

Desenvolvido por Guilherme Garcia
📧 DevGuiGarcia@hotmail.com

## 📌 Status do Projeto

#### 🚧 Em desenvolvimento

⚠️ Este projeto requer os arquivos google-services.json e GoogleService-Info.plist. Para rodar localmente, crie seu próprio projeto Firebase e adicione esses arquivos nos locais corretos. Devido a utilização de `rxdart` para construção de `MultiProviders`, é necessario configurar as permissões do DB.  
