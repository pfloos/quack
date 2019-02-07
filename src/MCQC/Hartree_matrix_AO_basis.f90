subroutine Hartree_matrix_AO_basis(nBas,P,Hc,G,H)

! Compute Hartree matrix in the AO basis

  implicit none
  include 'parameters.h'

! Input variables

  integer,intent(in)            :: nBas
  double precision,intent(in)   :: P(nBas,nBas)
  double precision,intent(in)   :: Hc(nBas,nBas),G(nBas,nBas,nBas,nBas)

! Local variables

  integer                       :: mu,nu,la,si

! Output variables

  double precision,intent(out)  :: H(nBas,nBas)

  H = Hc
  do mu=1,nBas
    do nu=1,nBas
      do la=1,nBas
        do si=1,nBas
          H(mu,nu) = H(mu,nu) + P(la,si)*G(mu,la,nu,si)
        enddo
      enddo
    enddo
  enddo

end subroutine Hartree_matrix_AO_basis
