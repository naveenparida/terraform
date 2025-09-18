resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Resident-VPC"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id     = aws_vpc.vpc.id
  region     = aws_vpc.vpc.region
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id     = aws_vpc.vpc.id
  region     = aws_vpc.vpc.region
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "PrivateSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# resource "aws_internet_gateway_attachment" "example" {
#   internet_gateway_id = aws_internet_gateway.igw.id
#   vpc_id              = aws_vpc.vpc.id
# }

resource "aws_route_table" "public_rotetable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.public_rotetable.id
}

resource "aws_route_table" "private_routetable" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }
  tags = {
    Name = "PrivateRouteTable"
  }

}

resource "aws_route_table_association" "private_assocication" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.private_routetable.id
}

resource "aws_eip" "eip" {
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet.id

  tags = {
    Name = "NGW"
  }
}


resource "aws_instance" "bastionhost" {
  ami           = "ami-0360c520857e2138f" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id = aws_subnet.publicsubnet.id
    associate_public_ip_address = true
    key_name = ""

  tags = {
    Name = "Basition-Host"
  }
}