import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  Unique,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Length, IsEmail, IsNotEmpty, IsOptional } from 'class-validator';
import { UserAddress } from './address/address.entity';
import { UserCard } from './card/card.entity';

import * as crypto from 'crypto';
import { CrudValidationGroups } from '@nestjsx/crud';

export function createSalt(length: number = 16) {
  return crypto.randomBytes(Math.ceil(length / 2))
    .toString('hex')
    .slice(0, length);
}

export function createHash(str: string, salt: string) {
  const hmac = crypto.createHmac('sha512', salt);
  hmac.update(str);
  return hmac.digest('hex');
}

const { CREATE, UPDATE } = CrudValidationGroups;

export const USER_EXCLUDES = ['salt', 'password'] as Array<keyof User>;

export type UserResponseDTO = Pick<User, Exclude<keyof User, 'password' | 'salt'>>;

/**
 * User Entity definition
 */
@Entity()
@Unique(['username'])
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @IsOptional({ groups: [UPDATE] })
  @IsNotEmpty({ groups: [CREATE] })
  @Column()
  username: string;

  @IsOptional({ groups: [UPDATE] })
  @IsNotEmpty({ groups: [CREATE] })
  @Column()
  password: string;

  @IsOptional({ always: true })
  @Column()
  salt: string;

  @IsNotEmpty({ groups: [CREATE]})
  @Column()
  firstName: string;

  @IsNotEmpty({ groups: [CREATE]})
  @Column()
  lastName: string;

  @IsOptional({ always: true })
  @IsEmail()
  @Column({ length: 100, nullable: true })
  email?: string;

  @IsOptional({ always: true })
  @Column({ length: 20, nullable: true })
  phone?: string;

  @OneToMany(type => UserAddress, addr => addr.user)
  addresses: Promise<UserAddress[]>;

  @OneToMany(type => UserCard, card => card.user)
  cards: Promise<UserCard[]>;

  @Column()
  @CreateDateColumn()
  createdAt: Date;

  @Column()
  @UpdateDateColumn()
  updatedAt: Date;

  /**
   * one-way password hashing
   */
  public static hashPassword<T extends Partial<User>>(dto: T): T {
    if (dto.password) {
      dto.salt = createSalt();
      dto.password = createHash(dto.password, dto.salt);
    }
    return dto;
  }

  /**
   * Authentication check
   * @param dto User dto
   * @param password plain text password
   */
  public static verifyPassword<T extends Partial<User>>(dto: T, password: string): boolean {
    return createHash(password, dto.salt) === dto.password;
  }
}
