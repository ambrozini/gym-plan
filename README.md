# GymPlan 🏋️‍♂️

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue.svg)](https://www.typescriptlang.org/)
[![Astro](https://img.shields.io/badge/Astro-5.0-purple.svg)](https://astro.build/)
[![React](https://img.shields.io/badge/React-19-blue.svg)](https://reactjs.org/)

## Project Description

GymPlan is a web application designed to help beginners and intermediate users create personalized strength training plans. It solves the common problem of not knowing how to create an effective workout routine by automating the process based on user data and preferences.

### Key Features

- User account management with secure authentication
- Detailed user profile creation
- Comprehensive exercise database
- AI-powered training plan generation
- Customizable workout plans
- Multiple plan management

## Tech Stack

### Frontend
- [Astro 5](https://astro.build/) - Modern static site builder
- [React 19](https://reactjs.org/) - UI component library
- [TypeScript 5](https://www.typescriptlang.org/) - Type-safe JavaScript
- [Tailwind 4](https://tailwindcss.com/) - Utility-first CSS framework
- [Shadcn/ui](https://ui.shadcn.com/) - Accessible React components

### Backend
- [Supabase](https://supabase.com/) - Backend-as-a-Service
  - PostgreSQL database
  - Authentication
  - Real-time capabilities

### AI Integration
- [Openrouter.ai](https://openrouter.ai/) - AI model access service

### Infrastructure
- GitHub Actions for CI/CD
- DigitalOcean for hosting

## Getting Started

### Prerequisites

- Node.js (version specified in .nvmrc)
- npm or yarn
- Supabase account
- Openrouter.ai API key

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gym-plan.git
cd gym-plan
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
Create a `.env` file in the root directory with the following variables:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENROUTER_API_KEY=your_openrouter_api_key
```

4. Start the development server:
```bash
npm run dev
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run test` - Run tests
- `npm run lint` - Run linter
- `npm run format` - Format code

## Project Scope

### MVP Features
- User registration and authentication
- Profile creation with personal data
- Exercise database access
- Training plan generation
- Plan customization and management

### Future Considerations
- Advanced progress tracking
- Detailed analytics and charts
- Admin panel for exercise database
- Social features
- AI-powered exercise technique verification

### Current Limitations
- Basic progress tracking only
- Limited exercise database
- No social features
- No advanced medical recommendations

## Project Status

GymPlan is currently in active development. The MVP version is being implemented with focus on core functionality and user experience.

### Known Issues
- No known issues at this time

### Roadmap
1. Complete MVP features
2. Implement basic progress tracking
3. Add exercise database expansion
4. Introduce social features
5. Develop advanced analytics

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
