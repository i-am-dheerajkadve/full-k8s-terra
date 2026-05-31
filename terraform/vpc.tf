resource "aws_vpc" "dheeraj_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-devops-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dheeraj_vpc.id

  tags = {
    Name        = "${var.environment}-devops-igw"
    Environment = var.environment
  }
}

# Public subnets are used for EKS worker nodes because this project is not using NAT Gateway.
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.dheeraj_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-subnet-1"
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.dheeraj_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.environment}-public-subnet-2"
    Environment              = var.environment
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Private subnets are created for future production improvement.
# No NAT Gateway is attached, so do not place worker nodes here unless you add NAT.
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.dheeraj_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name                              = "${var.environment}-private-subnet-1"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.dheeraj_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name                              = "${var.environment}-private-subnet-2"
    Environment                       = var.environment
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dheeraj_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_a1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_a2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dheeraj_vpc.id

  tags = {
    Name        = "${var.environment}-private-route-table-no-nat"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_a1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_a2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}
