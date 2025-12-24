import { IsOptional, ValidateIf, IsUrl, IsBoolean, IsString } from 'class-validator';

export class FacebookDto {
  @IsOptional()
  @ValidateIf(p => p.url)
  @IsUrl()
  url?: string;

  @IsOptional()
  @IsBoolean()
  isReel?: boolean;

  @IsOptional()
  @IsString()
  videoTitle?: string;
}
