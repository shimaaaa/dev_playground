resource "aws_vpc" "this" {
  cidr_block = local.vpc_cidr
  tags = {
    Name = local.app_name
  }
}

resource "aws_flow_log" "this" {
  log_destination      = aws_s3_bucket.flowlog.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
}

resource "aws_s3_bucket" "flowlog" {
  bucket = "${local.app_name}-flowlog"
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.this.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.app_name}-${each.value.name}"
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id = aws_vpc.this.id

  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${local.app_name}-${each.value.name}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.app_name}-igw"
  }
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "${local.app_name}-${each.value.name}-rt"
  }
}

resource "aws_route_table" "public" {
  for_each = local.public_subnets
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = "${local.app_name}-${each.value.name}-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "igw" {
  for_each               = local.public_subnets
  route_table_id         = aws_route_table.public[each.key].id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}
