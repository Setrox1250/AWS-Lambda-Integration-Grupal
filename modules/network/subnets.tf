# ─────────────────────────────────────────────────────────────────────────────
# modules/network/subnets.tf
# 4 subnets: 2 públicas (10.0.1/2.0/24) y 2 privadas (10.0.11/12.0/24)
# distribuidas en las dos primeras AZs disponibles de la cuenta
# ─────────────────────────────────────────────────────────────────────────────

# Subnets públicas

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = local.az_a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-a"
    Tier = "public"
    AZ   = local.az_a
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = local.az_b
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-b"
    Tier = "public"
    AZ   = local.az_b
  }
}

# Subnets privadas

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "${var.name_prefix}-private-a"
    Tier = "private"
    AZ   = local.az_a
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = local.az_b

  tags = {
    Name = "${var.name_prefix}-private-b"
    Tier = "private"
    AZ   = local.az_b
  }
}
