import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { User } from '../user.entity';
import { IsNotEmpty, Length, MinLength } from 'class-validator';

/**
 * User Card Entity definition
 */
@Entity()
export class UserCard {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', nullable: false })
  userId?: string;

  @Column({length: 10})
  number: string;

  @MinLength(10)
  @Column({length: 20})
  longNum: string;

  @IsNotEmpty()
  @Column()
  expires: string;

  @Column()
  @CreateDateColumn()
  createdAt: Date;

  @Column()
  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(type => User, user => user.cards)
  user: Promise<User>;

  /**
   * Mask card numbers before storage
   */
  public static redactNumbers<T extends Partial<UserCard>>(dto: T): T {
    dto.number = dto.longNum.slice(-4);
    dto.longNum = Array.apply(null, Array(12)).join('x') + dto.number;
    return dto;
  }

}
