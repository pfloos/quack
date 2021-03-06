subroutine RMFL20_lda_correlation_potential(LDA_centered,nEns,wEns,nGrid,weight,nBas,AO,rho,Fc)

! Compute Marut-Fromager-Loos weight-dependent LDA correlation potential

  implicit none
  include 'parameters.h'

! Input variables

  logical,intent(in)            :: LDA_centered
  integer,intent(in)            :: nEns
  double precision,intent(in)   :: wEns(nEns)
  integer,intent(in)            :: nGrid
  double precision,intent(in)   :: weight(nGrid)
  integer,intent(in)            :: nBas
  double precision,intent(in)   :: AO(nBas,nGrid)
  double precision,intent(in)   :: rho(nGrid)

! Local variables

  integer                       :: iEns
  double precision,allocatable  :: aMFL(:,:)
  double precision,allocatable  :: FcLDA(:,:)
  double precision,allocatable  :: FceLDA(:,:,:)

! Output variables

  double precision,intent(out)  :: Fc(nBas,nBas)

! Allocation

  allocate(aMFL(3,nEns),FcLDA(nBas,nBas),FceLDA(nBas,nBas,nEns))

! Parameters for weight-dependent LDA correlation functional

  aMFL(1,1) = -0.0238184d0
  aMFL(2,1) = +0.00540994d0
  aMFL(3,1) = +0.0830766d0

  aMFL(1,2) = -0.0282814d0
  aMFL(2,2) = +0.00273925d0
  aMFL(3,2) = +0.0664914d0

  aMFL(1,3) = -0.0144633d0
  aMFL(2,3) = -0.0506019d0
  aMFL(3,3) = +0.0331417d0

! Compute correlation energy for ground- and doubly-excited states

  do iEns=1,nEns
    call restricted_elda_correlation_potential(aMFL(1:3,iEns),nGrid,weight(:),nBas,AO(:,:),rho(:),FceLDA(:,:,iEns))
  end do

! LDA-centered functional

  if(LDA_centered) then

    call RVWN5_lda_correlation_potential(nGrid,weight(:),nBas,AO(:,:),rho(:),FcLDA(:,:))

    FceLDA(:,:,3) = FcLDA(:,:) + wEns(3)*(FceLDA(:,:,3) - FceLDA(:,:,1))
    FceLDA(:,:,2) = FcLDA(:,:) + wEns(2)*(FceLDA(:,:,2) - FceLDA(:,:,1))
    FceLDA(:,:,1) = FcLDA(:,:)

  end if

! Weight-denpendent functional for ensembles

  Fc(:,:) = 0d0
  do iEns=1,nEns
    Fc(:,:) = Fc(:,:) + wEns(iEns)*FceLDA(:,:,iEns)
  enddo

end subroutine RMFL20_lda_correlation_potential
