program eDFT

! exchange-correlation density-functional theory calculations

  include 'parameters.h'

  integer                       :: nNuc,nBas,nEl(nspin),nO(nspin),nV(nspin)
  double precision              :: ENuc,EKS

  double precision,allocatable  :: ZNuc(:),rNuc(:,:)

  integer                       :: nShell
  integer,allocatable           :: TotAngMomShell(:)
  integer,allocatable           :: KShell(:)
  double precision,allocatable  :: CenterShell(:,:)
  double precision,allocatable  :: DShell(:,:)
  double precision,allocatable  :: ExpShell(:,:)

  double precision,allocatable  :: S(:,:),T(:,:),V(:,:),Hc(:,:),X(:,:)
  double precision,allocatable  :: ERI(:,:,:,:)

  integer                       :: x_rung,c_rung
  character(len=12)             :: x_DFA ,c_DFA
  integer                       :: SGn
  integer                       :: nRad,nAng,nGrid
  double precision,allocatable  :: root(:,:)
  double precision,allocatable  :: weight(:)
  double precision,allocatable  :: AO(:,:)
  double precision,allocatable  :: dAO(:,:,:)

  double precision              :: start_KS,end_KS,t_KS

  integer                       :: nEns
  double precision,allocatable  :: wEns(:)

  integer                       :: maxSCF,max_diis
  double precision              :: thresh
  logical                       :: DIIS,guess_type,ortho_type

! Hello World

  write(*,*)
  write(*,*) '******************************************'
  write(*,*) '* eDFT: density-functional for ensembles *'
  write(*,*) '******************************************'
  write(*,*)

!------------------------------------------------------------------------
! Read input information
!------------------------------------------------------------------------

! Read number of atoms, number of electrons of the system
! nO   = number of occupied orbitals
! nV   = number of virtual orbitals (see below)
! nBas = number of basis functions (see below)
!      = nO + nV

  call read_molecule(nNuc,nEl,nO)
  allocate(ZNuc(nNuc),rNuc(nNuc,ncart))

! Read geometry

  call read_geometry(nNuc,ZNuc,rNuc,ENuc)

  allocate(CenterShell(maxShell,ncart),TotAngMomShell(maxShell),KShell(maxShell), &
           DShell(maxShell,maxK),ExpShell(maxShell,maxK))

!------------------------------------------------------------------------
! Read basis set information
!------------------------------------------------------------------------

  call read_basis(nNuc,rNuc,nBas,nO,nV,nShell,TotAngMomShell,CenterShell,KShell,DShell,ExpShell)

!------------------------------------------------------------------------
! Read one- and two-electron integrals
!------------------------------------------------------------------------

! Memory allocation for one- and two-electron integrals

  allocate(S(nBas,nBas),T(nBas,nBas),V(nBas,nBas),Hc(nBas,nBas),X(nBas,nBas), &
           ERI(nBas,nBas,nBas,nBas))

!   Read integrals

  call read_integrals(nBas,S,T,V,Hc,ERI)  

! Orthogonalization X = S^(-1/2)

  call orthogonalization_matrix(nBas,S,X)

!------------------------------------------------------------------------
! DFT options
!------------------------------------------------------------------------

! Allocate ensemble weights

  allocate(wEns(maxEns))

  call read_options(x_rung,x_DFA,c_rung,c_DFA,SGn,nEns,wEns,maxSCF,thresh,DIIS,max_diis,guess_type,ortho_type)

!------------------------------------------------------------------------
! Construct quadrature grid
!------------------------------------------------------------------------
  call read_grid(SGn,nRad,nAng,nGrid)

  allocate(root(ncart,nGrid),weight(nGrid))
  call quadrature_grid(nRad,nAng,nGrid,root,weight)

!------------------------------------------------------------------------
! Calculate AO values at grid points
!------------------------------------------------------------------------

  allocate(AO(nBas,nGrid),dAO(ncart,nBas,nGrid))
  call AO_values_grid(nBas,nShell,CenterShell,TotAngMomShell,KShell,DShell,ExpShell, &
                      nGrid,root,AO,dAO)

!------------------------------------------------------------------------
! Compute KS energy
!------------------------------------------------------------------------

    call cpu_time(start_KS)
    call Kohn_Sham(x_rung,x_DFA,c_rung,c_DFA,nEns,wEns(1:nEns),nGrid,weight(:),maxSCF,thresh,max_diis,guess_type, & 
                   nBas,AO(:,:),dAO(:,:,:),nO(:),nV(:),S(:,:),T(:,:),V(:,:),Hc(:,:),ERI(:,:,:,:),X(:,:),ENuc,EKS)
    call cpu_time(end_KS)

    t_KS = end_KS - start_KS
    write(*,'(A65,1X,F9.3,A8)') 'Total CPU time for KS = ',t_KS,' seconds'
    write(*,*)

!------------------------------------------------------------------------
! End of eDFT
!------------------------------------------------------------------------
end program eDFT