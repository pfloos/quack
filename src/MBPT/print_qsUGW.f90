subroutine print_qsUGW(nBas,nO,Ov,nSCF,Conv,thresh,eGW,cGW,PGW,T,V,J,K,ENuc,EHF,SigC,Z,EcRPA,dipole)

! Print one-electron energies and other stuff for qsUGW

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)                 :: nBas
  integer,intent(in)                 :: nO(nspin)
  double precision,intent(in)        :: Ov(nBas,nBas)
  integer,intent(in)                 :: nSCF
  double precision,intent(in)        :: ENuc
  double precision,intent(in)        :: EHF
  double precision,intent(in)        :: EcRPA
  double precision,intent(in)        :: Conv
  double precision,intent(in)        :: thresh
  double precision,intent(in)        :: eGW(nBas,nspin)
  double precision,intent(in)        :: cGW(nBas,nBas,nspin)
  double precision,intent(in)        :: PGW(nBas,nBas,nspin)
  double precision,intent(in)        :: T(nBas,nBas)
  double precision,intent(in)        :: V(nBas,nBas)
  double precision,intent(in)        :: J(nBas,nBas,nspin)
  double precision,intent(in)        :: K(nBas,nBas,nspin)
  double precision,intent(in)        :: SigC(nBas,nBas,nspin)
  double precision,intent(in)        :: Z(nBas,nspin)
  double precision,intent(in)        :: dipole(ncart)

! Local variables

  integer                            :: p
  integer                            :: ispin,ixyz
  double precision                   :: HOMO(nspin)
  double precision                   :: LUMO(nspin)
  double precision                   :: Gap(nspin)
  double precision                   :: ET(nspin)
  double precision                   :: EV(nspin)
  double precision                   :: EJ(nsp)
  double precision                   :: Ex(nspin)
  double precision                   :: Ec(nsp)
  double precision                   :: EqsGW
  double precision                   :: S_exact,S2_exact
  double precision                   :: S,S2
  double precision,external          :: trace_matrix

! HOMO and LUMO

  do ispin=1,nspin
    if(nO(ispin) > 0) then
      HOMO(ispin) = eGW(nO(ispin),ispin)
      LUMO(ispin) = eGW(nO(ispin)+1,ispin)
      Gap(ispin)  = LUMO(ispin) - HOMO(ispin)
    else
      HOMO(ispin) = 0d0
      LUMO(ispin) = eGW(1,ispin)
      Gap(ispin)  = 0d0
    end if
  end do

  S2_exact = dble(nO(1) - nO(2))/2d0*(dble(nO(1) - nO(2))/2d0 + 1d0)
  S2 = S2_exact + nO(2) - sum(matmul(transpose(cGW(:,1:nO(1),1)),matmul(Ov,cGW(:,1:nO(2),2)))**2)

  S_exact = 0.5d0*dble(nO(1) - nO(2))
  S = -0.5d0 + 0.5d0*sqrt(1d0 + 4d0*S2)

!------------------------------------------------------------------------
!   Compute total energy
!------------------------------------------------------------------------

!  Kinetic energy

    do ispin=1,nspin
      ET(ispin) = trace_matrix(nBas,matmul(PGW(:,:,ispin),T(:,:)))
    end do

!  Potential energy

    do ispin=1,nspin
      EV(ispin) = trace_matrix(nBas,matmul(PGW(:,:,ispin),V(:,:)))
    end do

!  Coulomb energy

    EJ(1) = 0.5d0*trace_matrix(nBas,matmul(PGW(:,:,1),J(:,:,1)))
    EJ(2) = trace_matrix(nBas,matmul(PGW(:,:,1),J(:,:,2)))
    EJ(3) = 0.5d0*trace_matrix(nBas,matmul(PGW(:,:,2),J(:,:,2)))

!   Exchange energy

    do ispin=1,nspin
      Ex(ispin) = 0.5d0*trace_matrix(nBas,matmul(PGW(:,:,ispin),K(:,:,ispin)))
    end do

!  Correlation energy

    Ec(1) = 0.5d0*trace_matrix(nBas,matmul(PGW(:,:,1),SigC(:,:,1)))
    Ec(2) = trace_matrix(nBas,matmul(PGW(:,:,1),SigC(:,:,2)))
    Ec(3) = 0.5d0*trace_matrix(nBas,matmul(PGW(:,:,2),SigC(:,:,2)))

!   Total energy

    EqsGW = sum(ET(:)) + sum(EV(:)) + sum(EJ(:)) + sum(Ex(:)) + sum(Ec(:))

! Dump results

  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  if(nSCF < 10) then
    write(*,'(1X,A21,I1,A1,I1,A12)')'  Self-consistent qsG',nSCF,'W',nSCF,' calculation'
  else
    write(*,'(1X,A21,I2,A1,I2,A12)')'  Self-consistent qsG',nSCF,'W',nSCF,' calculation'
  endif
  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  write(*,'(A1,A3,A1,A30,A1,A30,A1,A30,A1,A30,A1)') &
            '|',' ','|','e_HF            ','|','Sig_c            ','|','Z            ','|','e_QP            ','|'
  write(*,'(A1,A3,A1,2A15,A1,2A15,A1,2A15,A1,2A15,A1)') &
            '|','#','|','up     ','dw     ','|','up     ','dw     ','|','up     ','dw     ','|','up     ','dw     ','|'
  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'

  do p=1,nBas
    write(*,'(A1,I3,A1,2F15.6,A1,2F15.6,A1,2F15.6,A1,2F15.6,A1)') &
    '|',p,'|',eGW(p,1)*HaToeV,eGW(p,2)*HaToeV,'|',SigC(p,p,1)*HaToeV,SigC(p,p,2)*HaToeV,'|', &
              Z(p,1),Z(p,2),'|',eGW(p,1)*HaToeV,eGW(p,2)*HaToeV,'|'
  enddo

  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  write(*,'(2X,A10,I3)')   'Iteration ',nSCF
  write(*,'(2X,A19,F15.5)')'max(|FPS - SPF|) = ',Conv
  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  write(*,'(2X,A30,F15.6)') 'qsGW HOMO      energy (eV):',maxval(HOMO(:))*HaToeV
  write(*,'(2X,A30,F15.6)') 'qsGW LUMO      energy (eV):',minval(LUMO(:))*HaToeV
  write(*,'(2X,A30,F15.6)') 'qsGW HOMO-LUMO gap    (eV):',(minval(LUMO(:))-maxval(HOMO(:)))*HaToeV
  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  write(*,'(2X,A30,F15.6)') 'qsGW total       energy   =',EqsGW + ENuc
  write(*,'(2X,A30,F15.6)') 'qsGW exchange    energy   =',sum(Ex(:))
  write(*,'(2X,A30,F15.6)') 'qsGW correlation energy   =',sum(Ec(:))
  write(*,'(2X,A30,F15.6)') 'RPA@qsGW correlation energy =',EcRPA
  write(*,*)'-------------------------------------------------------------------------------& 
              -------------------------------------------------'
  write(*,*)

! Dump results for final iteration

  if(Conv < thresh) then

    write(*,*)
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A40)')              ' Summary              '
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A40,1X,F16.10,A3)') ' One-electron    energy: ',sum(ET(:))  + sum(EV(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' One-electron a  energy: ',ET(1) + EV(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' One-electron b  energy: ',ET(2) + EV(2),' au'
    write(*,*)
    write(*,'(A40,1X,F16.10,A3)') ' Kinetic         energy: ',sum(ET(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Kinetic      a  energy: ',ET(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Kinetic      b  energy: ',ET(2),' au'
    write(*,*)
    write(*,'(A40,1X,F16.10,A3)') ' Potential       energy: ',sum(EV(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Potential    a  energy: ',EV(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Potential    b  energy: ',EV(2),' au'
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A40,1X,F16.10,A3)') ' Two-electron    energy: ',sum(EJ(:)) + sum(Ex(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Two-electron aa energy: ',EJ(1) + Ex(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Two-electron ab energy: ',EJ(2),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Two-electron bb energy: ',EJ(3) + Ex(2),' au'
    write(*,*)
    write(*,'(A40,1X,F16.10,A3)') ' Coulomb         energy: ',sum(EJ(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Coulomb      aa energy: ',EJ(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Coulomb      ab energy: ',EJ(2),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Coulomb      bb energy: ',EJ(3),' au'
    write(*,*)
    write(*,'(A40,1X,F16.10,A3)') ' Exchange        energy: ',sum(Ex(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Exchange     a  energy: ',Ex(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Exchange     b  energy: ',Ex(2),' au'
    write(*,*)
    write(*,'(A40,1X,F16.10,A3)') ' Correlation     energy: ',sum(Ec(:)),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Correlation  aa energy: ',Ec(1),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Correlation  ab energy: ',Ec(2),' au'
    write(*,'(A40,1X,F16.10,A3)') ' Correlation  bb energy: ',Ec(3),' au'
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A40,1X,F16.10,A3)') ' Electronic      energy: ',EqsGW,' au'
    write(*,'(A40,1X,F16.10,A3)') ' Nuclear      repulsion: ',ENuc,' au'
    write(*,'(A40,1X,F16.10,A3)') ' qsUGW           energy: ',EqsGW + ENuc,' au'
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A40,F13.6)')        '  S (exact)          :',2d0*S_exact + 1d0
    write(*,'(A40,F13.6)')        '  S                  :',2d0*S       + 1d0
    write(*,'(A40,F13.6)')        ' <S**2> (exact)      :',S2_exact
    write(*,'(A40,F13.6)')        ' <S**2>              :',S2
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,'(A45)')              ' Dipole moment (Debye)    '
    write(*,'(19X,4A10)')         'X','Y','Z','Tot.'
    write(*,'(19X,4F10.6)')       (dipole(ixyz)*auToD,ixyz=1,ncart),norm2(dipole)*auToD
    write(*,'(A60)')              '-------------------------------------------------'
    write(*,*)

  endif

end subroutine print_qsUGW