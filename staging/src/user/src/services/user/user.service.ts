import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { TypeOrmCrudService } from '@nestjsx/crud-typeorm';
import { User, UserResponseDTO } from './user.entity';
import { Repository } from 'typeorm';

@Injectable()
export class UserService extends TypeOrmCrudService<User> {

  constructor(@InjectRepository(User) repo: Repository<User>) {
    super(repo);
  }

  /**
   * Find user by a username
   * @param username
   */
  findByUsername(username: string): Promise<User | undefined> {
    return this.repo.findOne({where: { username }});
  }

  /**
   * Verify a user password
   * @param user user with salt
   * @param password plain password
   */
  verifyPassword(user: User, password: string): boolean {
    return user && User.verifyPassword(user, password);
  }

  /**
   * Filter DTO properties
   * @param user User object
   */
  filterDTO<T extends User>(user: T): UserResponseDTO {
    const { salt, password, ...rest } = user;
    return rest;
  }
}
