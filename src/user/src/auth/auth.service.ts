import { Injectable } from '@nestjs/common';
import { UserService } from '../services/user/user.service';
import { User, UserResponseDTO } from '../services/user/user.entity';

@Injectable()
export class AuthService {
  constructor(private readonly usersService: UserService) {}

  async validateUser(username: string, pass: string): Promise<UserResponseDTO | null> {
    const user: User = await this.usersService.findByUsername(username);
    return this.usersService.verifyPassword(user, pass) ?
      this.usersService.filterDTO(user) :
      null;
  }

}
