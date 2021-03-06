subroutine print_UKS(nBas,nEns,nO,Ov,wEns,eps,c,ENuc,ET,EV,EJ,Ex,Ec,Ew,dipole)

! Print one- and two-electron energies and other stuff for KS calculation

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)                 :: nBas
  integer,intent(in)                 :: nEns
  integer,intent(in)                 :: nO(nspin)
  double precision,intent(in)        :: Ov(nBas,nBas)
  double precision,intent(in)        :: wEns(nEns)
  double precision,intent(in)        :: eps(nBas,nspin)
  double precision,intent(in)        :: c(nBas,nBas,nspin)
  double precision,intent(in)        :: ENuc
  double precision,intent(in)        :: ET(nspin)
  double precision,intent(in)        :: EV(nspin)
  double precision,intent(in)        :: EJ(nsp)
  double precision,intent(in)        :: Ex(nspin)
  double precision,intent(in)        :: Ec(nsp)
  double precision,intent(in)        :: Ew
  double precision,intent(in)        :: dipole(ncart)

! Local variables

  integer                            :: ixyz
  integer                            :: ispin
  integer                            :: iEns
  integer                            :: iBas
  integer                            :: HOMO(nspin)
  integer                            :: LUMO(nspin)
  double precision                   :: Gap(nspin)
  double precision                   :: S_exact,S2_exact
  double precision                   :: S,S2

! HOMO and LUMO

  do ispin=1,nspin

      HOMO(ispin) = nO(ispin)
      LUMO(ispin) = HOMO(ispin) + 1
      Gap(ispin)  = eps(LUMO(ispin),ispin) - eps(HOMO(ispin),ispin)

  end do

! Spin comtamination

  S2_exact = dble(nO(1) - nO(2))/2d0*(dble(nO(1) - nO(2))/2d0 + 1d0)
  S2 = S2_exact + nO(2) - sum(matmul(transpose(c(:,1:nO(1),1)),matmul(Ov,c(:,1:nO(2),2)))**2)

  S_exact = 0.5d0*dble(nO(1) - nO(2))
  S = -0.5d0 + 0.5d0*sqrt(1d0 + 4d0*S2)

! Dump results

  write(*,*)
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40)')              ' Summary              '
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,1X,F16.10,A3)') ' One-electron    energy: ',sum(ET(:))  + sum(EV(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' One-electron a  energy: ',ET(1) + EV(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' One-electron b  energy: ',ET(2) + EV(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Kinetic         energy: ',sum(ET(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Kinetic      a  energy: ',ET(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Kinetic      b  energy: ',ET(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Potential       energy: ',sum(EV(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Potential    a  energy: ',EV(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Potential    b  energy: ',EV(2),' au'
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,1X,F16.10,A3)') ' Two-electron a  energy: ',sum(EJ(:)) + sum(Ex(:))  + sum(Ec(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Two-electron aa energy: ',EJ(1) + Ex(1) + Ec(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Two-electron ab energy: ',EJ(2) + Ec(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Two-electron bb energy: ',EJ(3) + Ex(2) + Ec(3),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Coulomb         energy: ',sum(EJ(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Coulomb      aa energy: ',EJ(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Coulomb      ab energy: ',EJ(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Coulomb      bb energy: ',EJ(3),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Exchange        energy: ',sum(Ex(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Exchange     a  energy: ',Ex(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Exchange     b  energy: ',Ex(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Correlation     energy: ',sum(Ec(:)),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Correlation  aa energy: ',Ec(1),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Correlation  ab energy: ',Ec(2),' au'
  write(*,'(A40,1X,F16.10,A3)') ' Correlation  bb energy: ',Ec(3),' au'
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,1X,F16.10,A3)') ' Electronic      energy: ',Ew,' au'
  write(*,'(A40,1X,F16.10,A3)') ' Nuclear      repulsion: ',ENuc,' au'
  write(*,'(A40,1X,F16.10,A3)') ' Kohn-Sham       energy: ',Ew + ENuc,' au'
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,F13.6,A3)')     ' KS HOMO a    energy:',eps(HOMO(1),1)*HatoeV,' eV'
  write(*,'(A40,F13.6,A3)')     ' KS LUMO a    energy:',eps(LUMO(1),1)*HatoeV,' eV'
  write(*,'(A40,F13.6,A3)')     ' KS HOMOa-LUMOa  gap:',Gap(1)*HatoeV,' eV'
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,F13.6,A3)')     ' KS HOMO b    energy:',eps(HOMO(2),2)*HatoeV,' eV'
  write(*,'(A40,F13.6,A3)')     ' KS LUMO b    energy:',eps(LUMO(2),2)*HatoeV,' eV'
  write(*,'(A40,F13.6,A3)')     ' KS HOMOb-LUMOb gap :',Gap(2)*HatoeV,' eV'
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A40,1X,F16.6)')     '  S (exact)          :',2d0*S_exact + 1d0
  write(*,'(A40,1X,F16.6)')     '  S                  :',2d0*S       + 1d0
  write(*,'(A40,1X,F16.6)')     ' <S**2> (exact)      :',S2_exact
  write(*,'(A40,1X,F16.6)')     ' <S**2>              :',S2
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,'(A45)')              ' Dipole moment (Debye)    '
  write(*,'(19X,4A10)')         'X','Y','Z','Tot.'
  write(*,'(19X,4F10.6)')       (dipole(ixyz)*auToD,ixyz=1,ncart),norm2(dipole)*auToD
  write(*,'(A60)')              '-------------------------------------------------'
  write(*,*)

! Print results

  write(*,'(A50)') '-----------------------------------------'
  write(*,'(A50)') 'Kohn-Sham spin-up   orbital coefficients '
  write(*,'(A50)') '-----------------------------------------'
  call matout(nBas,nBas,c(:,:,1))
  write(*,'(A50)') '-----------------------------------------'
  write(*,'(A50)') 'Kohn-Sham spin-down orbital coefficients '
  write(*,'(A50)') '-----------------------------------------'
  call matout(nBas,nBas,c(:,:,2))
  write(*,*)
  write(*,'(A50)') '---------------------------------------'
  write(*,'(A50)') ' Kohn-Sham spin-up   orbital energies  '
  write(*,'(A50)') '---------------------------------------'
  call matout(nBas,1,eps(:,1))
  write(*,*)
  write(*,'(A50)') '---------------------------------------'
  write(*,'(A50)') ' Kohn-Sham spin-down orbital energies  '
  write(*,'(A50)') '---------------------------------------'
  call matout(nBas,1,eps(:,2))
  write(*,*)

end subroutine print_UKS
