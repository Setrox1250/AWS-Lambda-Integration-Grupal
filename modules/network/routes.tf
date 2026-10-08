# ─────────────────────────────────────────────────────────────────────────────
# modules/network/routes.tf
# Route tables y asociaciones:
#   - Pública (compartida A y B) → 0.0.0.0/0 a IGW
#   - Privada-A → 0.0.0.0/0 a NAT-A  (egreso independiente por AZ)
#   - Privada-B → 0.0.0.0/0 a NAT-B  (egreso independiente por AZ)
# Elastic IPs y NAT Gateways también se definen aquí
# ─────────────────────────────────────────────────────────────────────────────

# Elastic IPs para los NAT Gateways

resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-eip-nat-a"
    AZ   = local.az_a
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-eip-nat-b"
    AZ   = local.az_b
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways (uno por AZ, en subnet pública)
# Riesgo: Cada subred privada usa exclusivamente el NAT de su propia zona
# Si el NAT de la zona A falla, el tráfico no se redirige automáticamente al NAT de la zona B

resource "aws_nat_gateway" "a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name = "${var.name_prefix}-nat-a"
    AZ   = local.az_a
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  tags = {
    Name = "${var.name_prefix}-nat-b"
    AZ   = local.az_b
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table pública (A y B comparten IGW)

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Route tables privadas (independientes por AZ)

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.a.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-private-a"
    AZ   = local.az_a
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.b.id
  }

  tags = {
    Name = "${var.name_prefix}-rt-private-b"
    AZ   = local.az_b
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
