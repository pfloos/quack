subroutine linear_response_pp(ispin,BSE,nBas,nC,nO,nV,nR,nOO,nVV,e,ERI,Omega1,X1,Y1,Omega2,X2,Y2,Ec_ppRPA)

! Compute the p-p channel of the linear response: see Scueria et al. JCP 139, 104113 (2013)

  implicit none
  include 'parameters.h'

! Input variables

  logical,intent(in)            :: BSE
  integer,intent(in)            :: ispin,nBas,nC,nO,nV,nR
  integer,intent(in)            :: nOO
  integer,intent(in)            :: nVV
  double precision,intent(in)   :: e(nBas)
  double precision,intent(in)   :: ERI(nBas,nBas,nBas,nBas)
  
! Local variables

  double precision              :: trace_matrix
  double precision,allocatable  :: B(:,:)
  double precision,allocatable  :: C(:,:)
  double precision,allocatable  :: D(:,:)
  double precision,allocatable  :: M(:,:)
  double precision,allocatable  :: Z(:,:)
  double precision,allocatable  :: Omega(:)

! Output variables

  double precision,intent(out)  :: Omega1(nVV)
  double precision,intent(out)  :: X1(nVV,nVV)
  double precision,intent(out)  :: Y1(nOO,nVV)
  double precision,intent(out)  :: Omega2(nOO)
  double precision,intent(out)  :: X2(nVV,nOO)
  double precision,intent(out)  :: Y2(nOO,nOO)
  double precision,intent(out)  :: Ec_ppRPA

! Memory allocation

  allocate(B(nVV,nOO),C(nVV,nVV),D(nOO,nOO),M(nOO+nVV,nOO+nVV),Z(nOO+nVV,nOO+nVV),Omega(nOO+nVV))

! Build B, C and D matrices for the pp channel

  call linear_response_B_pp(ispin,nBas,nC,nO,nV,nR,nOO,nVV,e,ERI,B)
  call linear_response_C_pp(ispin,nBas,nC,nO,nV,nR,nOO,nVV,e,ERI,C)
  call linear_response_D_pp(ispin,nBas,nC,nO,nV,nR,nOO,nVV,e,ERI,D)

!------------------------------------------------------------------------
! Solve the p-p eigenproblem
!------------------------------------------------------------------------
!
!  | C   -B | | X1  X2 |   | w1  0  | | X1  X2 |
!  |        | |        | = |        | |        |
!  | Bt  -D | | Y1  Y2 |   | 0   w2 | | Y1  Y2 |
!

! Diagonal blocks 

  M(    1:nVV    ,    1:nVV)     = + C(1:nVV,1:nVV)
  M(nVV+1:nVV+nOO,nVV+1:nVV+nOO) = - D(1:nOO,1:nOO)

! Off-diagonal blocks

  M(    1:nVV    ,nVV+1:nOO+nVV) = +           B(1:nVV,1:nOO)
  M(nVV+1:nOO+nVV,    1:nVV)     = - transpose(B(1:nVV,1:nOO))

! print*, 'pp-RPA matrix'
! call matout(nOO+nVV,nOO+nVV,M(:,:))

! Diagonalize the p-h matrix

  Z(:,:) = M(:,:)
  call diagonalize_general_matrix(nOO+nVV,M(:,:),Omega(:),Z(:,:))

! write(*,*) 'pp-RPA excitation energies'
! call matout(nOO+nVV,1,Omega(:))
! write(*,*) 

! Split the various quantities in p-p and h-h parts

  call sort_ppRPA(nOO,nVV,Omega(:),Z(:,:),Omega1(:),X1(:,:),Y1(:,:),Omega2(:),X2(:,:),Y2(:,:))

! Compute the RPA correlation energy

! Ec_ppRPA = 0.5d0*( sum(Omega1(:)) - sum(Omega2(:)) - trace_matrix(nVV,C(:,:)) - trace_matrix(nOO,D(:,:)) )
  Ec_ppRPA = +sum(Omega1(:)) - trace_matrix(nVV,C(:,:))
! Ec_ppRPA = -sum(Omega2(:)) - trace_matrix(nOO,D(:,:))

! write(*,*)'X1'
! call matout(nVV,nVV,X1)
! write(*,*)'Y1'
! call matout(nVV,nOO,Y1)
! write(*,*)'X2'
! call matout(nOO,nVV,X2)
! write(*,*)'Y2'
! call matout(nOO,nOO,Y2)

! print*,'Ec(pp-RPA) = ',Ec_ppRPA

end subroutine linear_response_pp