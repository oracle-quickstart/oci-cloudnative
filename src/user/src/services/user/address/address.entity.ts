import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { IsNotEmpty } from 'class-validator';
import { User } from '../user.entity';

/**
 * User Address Entity definition
 */
@Entity()
export class UserAddress {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', nullable: false })
  userId?: string;

  @IsNotEmpty()
  @Column()
  number: string;

  @IsNotEmpty()
  @Column()
  street: string;

  @IsNotEmpty()
  @Column()
  city: string;

  @IsNotEmpty()
  @Column()
  country: string;

  @IsNotEmpty()
  @Column()
  postcode: string;

  @Column()
  @CreateDateColumn()
  createdAt: Date;

  @Column()
  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(type => User, user => user.addresses)
  user: User;
}
