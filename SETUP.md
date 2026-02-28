# 🚀 AlanoCryptoFX - Guia de Configuração

## 📋 Pré-requisitos

- Flutter SDK (versão 3.9.0 ou superior)
- Dart SDK
- Android Studio / Xcode (para desenvolvimento mobile)
- Conta no Firebase
- Conta no Google Cloud Console

## 🔧 Configuração do Projeto

### 1. Instalar Dependências

```bash
flutter pub get
```

### 2. Configurar Firebase

#### 2.1. Criar Projeto no Firebase

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Ative o Authentication com provedor Google
4. Ative o Firestore Database
5. Ative o Storage (opcional, para upload de imagens)

#### 2.2. Configurar Firebase no App

**Android:**

1. Baixe o arquivo `google-services.json`
2. Coloque em `android/app/google-services.json`
3. Adicione ao `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

4. Adicione ao `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

**iOS:**

1. Baixe o arquivo `GoogleService-Info.plist`
2. Adicione ao projeto iOS via Xcode

#### 2.3. Estrutura do Firestore

```javascript
// Coleção: users
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoURL": "string",
  "isMember": boolean,
  "createdAt": timestamp,
  "lastLogin": timestamp
}

// Coleção: posts
{
  "userId": "string",
  "userName": "string",
  "userPhoto": "string",
  "content": "string",
  "timestamp": timestamp,
  "likes": number,
  "likedBy": ["userId1", "userId2"],
  "comments": number
}

// Coleção: alano_posts
{
  "title": "string",
  "content": "string",
  "videoUrl": "string",
  "timestamp": timestamp,
  "likes": number,
  "comments": number,
  "views": number
}

// Coleção: signals
{
  "coin": "string",
  "type": "LONG" | "SHORT",
  "entry": "string",
  "targets": ["string"],
  "stopLoss": "string",
  "status": "string",
  "profit": "string",
  "timestamp": timestamp,
  "confidence": "Alta" | "Média" | "Baixa"
}

// Coleção: notifications
{
  "userId": "string",
  "type": "comment" | "reply" | "signal",
  "title": "string",
  "content": "string",
  "timestamp": timestamp,
  "read": boolean
}
```

### 3. Configurar YouTube API

#### 3.1. Ativar YouTube Data API v3

1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Selecione seu projeto (mesmo do Firebase)
3. Vá em "APIs e Serviços" > "Biblioteca"
4. Procure por "YouTube Data API v3"
5. Clique em "Ativar"

#### 3.2. Criar Credenciais OAuth 2.0

1. Vá em "APIs e Serviços" > "Credenciais"
2. Crie credenciais do tipo "ID do cliente OAuth 2.0"
3. Tipo: Aplicativo da Web
4. Adicione as URIs de redirecionamento autorizados

#### 3.3. Configurar no Código

No arquivo `lib/features/auth/services/auth_service.dart`, atualize:

```dart
// ID do canal do YouTube
static const String CHANNEL_ID = 'SEU_CHANNEL_ID_AQUI';
```

### 4. Regras de Segurança do Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Função para verificar se o usuário está autenticado
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Função para verificar se é o dono do documento
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Usuários
    match /users/{userId} {
      allow read: if isSignedIn();
      allow write: if isOwner(userId);
    }
    
    // Posts
    match /posts/{postId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Posts do Alano (apenas admin pode criar)
    match /alano_posts/{postId} {
      allow read: if isSignedIn();
      allow write: if false; // Apenas via admin SDK
    }
    
    // Sinais (apenas admin pode criar)
    match /signals/{signalId} {
      allow read: if isSignedIn();
      allow write: if false; // Apenas via admin SDK
    }
    
    // Notificações
    match /notifications/{notificationId} {
      allow read, update: if isOwner(resource.data.userId);
      allow create: if isSignedIn();
    }
  }
}
```

### 5. Assets

Certifique-se de ter os seguintes assets na pasta `assets/`:

- `logo.jpeg` - Logo do app/canal
- `google_logo.png` - Logo do Google (opcional)

## 📱 Estrutura de Pastas

```
lib/
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   └── widgets/
│   │       └── social_login_button.dart
│   ├── dashboard/
│   │   └── screens/
│   │       └── dashboard_screen.dart
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart
│   ├── profile/
│   │   └── screens/
│   │       └── profile_screen.dart
│   ├── alano_posts/
│   │   └── screens/
│   │       └── alano_posts_screen.dart
│   ├── ai_chat/
│   │   └── screens/
│   │       └── ai_chat_screen.dart
│   └── signals/
│       └── screens/
│           └── signals_screen.dart
├── theme/
│   └── app_theme.dart
└── main.dart
```

## 🎨 Paleta de Cores

- **Verde Principal:** `#00ff01` - Botões e destaques
- **Verde Secundário:** `#00FF88` - Logos e ícones
- **Azul Escuro de Fundo:** `#0E1116` - Background principal
- **Azul Escuro Secundário:** `#0E1629` - Cards e containers
- **Branco:** `#FFFFFF` - Textos

## ⚙️ Funcionalidades Implementadas

- ✅ Login com Google
- ✅ Verificação de membership do YouTube
- ✅ Dashboard com 5 abas
- ✅ Feed de posts da comunidade
- ✅ Perfil do usuário com estatísticas
- ✅ Posts exclusivos do Alano
- ✅ Chat com IA (simulado - precisa integração)
- ✅ Sinais de trading
- ✅ Sistema de notificações
- ✅ Tema dark customizado

## 🔜 Próximos Passos

1. **Integrar API de IA real** para o chat
2. **Implementar sistema de comentários** nos posts
3. **Adicionar push notifications**
4. **Criar painel admin** para o Alano postar sinais e conteúdo
5. **Implementar analytics** para acompanhar engajamento
6. **Adicionar sistema de gamificação** (badges, níveis)
7. **Implementar refresh automático** dos sinais
8. **Adicionar gráficos** para visualização de performance

## 🐛 Debugging

### Problemas Comuns

**Erro de autenticação:**
- Verifique se o SHA-1 está configurado no Firebase Console
- Certifique-se de que o `google-services.json` está correto

**Erro na verificação de membership:**
- A API do YouTube precisa estar ativa
- O canal precisa ter a API de membership habilitada
- Por enquanto, a verificação retorna `true` em desenvolvimento

**Erro ao carregar imagens:**
- Verifique se os assets estão no `pubspec.yaml`
- Execute `flutter pub get` novamente

## 📞 Suporte

Para dúvidas ou problemas, entre em contato com o desenvolvedor.

## 📄 Licença

Projeto privado - Todos os direitos reservados para AlanoCryptoFX